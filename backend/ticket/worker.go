package ticket

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"swift_transit/domain"
	"swift_transit/infra/rabbitmq"

	"github.com/google/uuid"
)

type TicketWorker struct {
	svc      Service
	rabbitMQ *rabbitmq.RabbitMQ
}

func NewTicketWorker(svc Service, rabbitMQ *rabbitmq.RabbitMQ) *TicketWorker {
	return &TicketWorker{
		svc:      svc,
		rabbitMQ: rabbitMQ,
	}
}

func (w *TicketWorker) Start() {
	q, err := w.rabbitMQ.DeclareQueue("ticket_queue")
	if err != nil {
		log.Fatalf("Failed to declare queue: %v", err)
	}

	msgs, err := w.rabbitMQ.Channel.Consume(
		q.Name, // queue
		"",     // consumer
		true,   // auto-ack
		false,  // exclusive
		false,  // no-local
		false,  // no-wait
		nil,    // args
	)
	if err != nil {
		log.Fatalf("Failed to register a consumer: %v", err)
	}

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			log.Printf("Received a message: %s", d.Body)

			var req TicketRequestMessage
			err := json.Unmarshal(d.Body, &req)
			if err != nil {
				log.Printf("Error decoding JSON: %s", err)
				continue
			}

			trackingID := ""
			if val, ok := d.Headers["tracking_id"]; ok {
				trackingID = val.(string)
			}

			w.ProcessTicket(req, trackingID)
		}
	}()

	log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
	<-forever
}

func (w *TicketWorker) ProcessTicket(req TicketRequestMessage, trackingID string) {
	// This logic is similar to the original BuyTicket but adapted for background processing
	// We need to access the service's internal dependencies, but since we are in the same package,
	// we can cast the interface to the struct if needed, or better, expose a method on the service
	// to handle the actual processing.
	// However, `Service` interface doesn't have `ProcessTicket`.
	// Let's implement the logic here using the service methods where possible,
	// but wait, `BuyTicket` in service is now the producer.
	// We need the logic that WAS in `BuyTicket` (DB insert, Payment Init).

	// Since `TicketWorker` is in `ticket` package, it can access `service` struct fields if we pass `*service` instead of `Service` interface.
	// Or we can add a `ProcessTicketInternal` method to `Service` interface (not ideal for public API).
	// Or we can just duplicate the logic/move it to a helper in `service.go`.

	// Let's cast the service to `*service` to access dependencies.
	s, ok := w.svc.(*service)
	if !ok {
		log.Printf("Service is not of type *service")
		return
	}

	baseURL := s.publicBaseURL

	if req.Quantity == 0 {
		req.Quantity = 1
	}

	batchID := req.BatchID
	if batchID == "" {
		batchID = uuid.New().String()
	}

	paymentRef := fmt.Sprintf("TICKET-%s", uuid.New().String()[:8])
	now := time.Now().Format(time.RFC3339)
	paymentStatus := "pending"
	paidStatus := false
	paymentUsed := false

	if req.PaymentMethod == "wallet" {
		// Deduct balance for all tickets together
		err := s.userRepo.DeductBalance(req.UserId, req.TotalFare)
		if err != nil {
			log.Printf("Payment failed: %v", err)
			statusData := map[string]interface{}{
				"status": "failed",
				"error":  "Insufficient balance",
			}
			statusJSON, _ := json.Marshal(statusData)
			s.redis.Set(s.ctx, fmt.Sprintf("ticket_status:%s", trackingID), statusJSON, 1*time.Hour)
			return
		}
		paidStatus = true
		paymentStatus = "paid"
		paymentUsed = true
	}

	var ticketIDs []int64
	for i := 0; i < req.Quantity; i++ {
		qrCode := uuid.New().String()
		ticket := domain.Ticket{
			UserId:           req.UserId,
			RouteId:          req.RouteId,
			BusName:          req.BusName,
			StartDestination: req.StartDestination,
			EndDestination:   req.EndDestination,
			Fare:             req.Fare,
			PaidStatus:       paidStatus,
			Checked:          false,
			QRCode:           qrCode,
			CreatedAt:        now,
			BatchID:          batchID,
			PaymentMethod:    req.PaymentMethod,
			PaymentReference: paymentRef,
			PaymentStatus:    paymentStatus,
			PaymentUsed:      paymentUsed,
		}

		createdTicket, err := s.repo.Create(ticket)
		if err != nil {
			log.Printf("Failed to create ticket: %v", err)
			statusData := map[string]interface{}{
				"status": "failed",
				"error":  "Failed to create ticket",
			}
			statusJSON, _ := json.Marshal(statusData)
			s.redis.Set(s.ctx, fmt.Sprintf("ticket_status:%s", trackingID), statusJSON, 1*time.Hour)
			return
		}
		ticketIDs = append(ticketIDs, createdTicket.Id)
	}

	if req.PaymentMethod == "wallet" {
		statusData := map[string]interface{}{
			"status":     "paid",
			"url":        fmt.Sprintf("/ticket/download?id=%d", ticketIDs[0]),
			"ticket_id":  ticketIDs[0],
			"ticket_ids": ticketIDs,
		}
		statusJSON, _ := json.Marshal(statusData)
		s.redis.Set(s.ctx, fmt.Sprintf("ticket_status:%s", trackingID), statusJSON, 1*time.Hour)

	} else {
		tranID := fmt.Sprintf("TICKET-%d-%s", ticketIDs[0], batchID[:8])
		successUrl := fmt.Sprintf("%s/ticket/payment/success?id=%d", baseURL, ticketIDs[0])
		failUrl := fmt.Sprintf("%s/ticket/payment/fail?id=%d", baseURL, ticketIDs[0])
		cancelUrl := fmt.Sprintf("%s/ticket/payment/cancel?id=%d", baseURL, ticketIDs[0])

		gatewayUrl, err := s.sslCommerz.InitPayment(req.TotalFare, tranID, successUrl, failUrl, cancelUrl)
		if err != nil {
			log.Printf("Gateway init failed: %v", err)
			statusData := map[string]interface{}{
				"status": "failed",
				"error":  "Gateway init failed",
			}
			statusJSON, _ := json.Marshal(statusData)
			s.redis.Set(s.ctx, fmt.Sprintf("ticket_status:%s", trackingID), statusJSON, 1*time.Hour)
			return
		}

		statusData := map[string]interface{}{
			"status":     "ready",
			"url":        gatewayUrl,
			"ticket_id":  ticketIDs[0],
			"ticket_ids": ticketIDs,
		}
		statusJSON, _ := json.Marshal(statusData)
		s.redis.Set(s.ctx, fmt.Sprintf("ticket_status:%s", trackingID), statusJSON, 1*time.Hour)
	}
}
