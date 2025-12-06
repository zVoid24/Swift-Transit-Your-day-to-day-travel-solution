package ticket

import (
	"encoding/json"
	"log"

	"swift_transit/infra/rabbitmq"
)

type TicketCheckWorker struct {
	svc      Service
	rabbitMQ *rabbitmq.RabbitMQ
	repo     TicketRepo
}

func NewTicketCheckWorker(svc Service, repo TicketRepo, rabbitMQ *rabbitmq.RabbitMQ) *TicketCheckWorker {
	return &TicketCheckWorker{
		svc:      svc,
		repo:     repo,
		rabbitMQ: rabbitMQ,
	}
}

func (w *TicketCheckWorker) Start() {
	ch, err := w.rabbitMQ.Conn.Channel()
	if err != nil {
		log.Fatalf("Failed to open a channel: %v", err)
	}
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"ticket_check_queue", // name
		true,                 // durable
		false,                // delete when unused
		false,                // exclusive
		false,                // no-wait
		nil,                  // arguments
	)
	if err != nil {
		log.Fatalf("Failed to declare queue: %v", err)
	}

	msgs, err := ch.Consume(
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
			log.Printf("Received a check event: %s", d.Body)

			var event map[string]interface{}
			err := json.Unmarshal(d.Body, &event)
			if err != nil {
				log.Printf("Error decoding JSON: %s", err)
				continue
			}

			w.ProcessCheck(event)
		}
	}()

	log.Printf(" [*] Waiting for check events. To exit press CTRL+C")
	<-forever
}

func (w *TicketCheckWorker) ProcessCheck(event map[string]interface{}) {
	ticketID := int64(event["ticket_id"].(float64))
	// currentStoppage := event["current_stoppage"].(string)

	// 1. Update Ticket Status in DB
	// We need a method in repo to mark as checked.
	// Reusing ValidateTicket or creating a new one.
	// ValidateTicket in repo updates `checked` to true.
	if err := w.repo.ValidateTicket(ticketID); err != nil {
		log.Printf("Failed to update ticket status in DB: %v", err)
	}

	// 2. Extra Fare Logic (Placeholder)
	// Compare currentStoppage with ticket.EndDestination
	// If different/further, calculate extra fare.
	// For now, just log it.
	log.Printf("Ticket %d checked at %s", ticketID, event["current_stoppage"])
}
