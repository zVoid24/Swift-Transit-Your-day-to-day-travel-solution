package bus

import (
	"encoding/json"
	"net/http"
)

type ValidateTicketRequest struct {
	TicketID int64 `json:"ticket_id"`
}

func (h *Handler) ValidateTicket(w http.ResponseWriter, r *http.Request) {
	var req ValidateTicketRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	busData, err := h.BusFromContext(r)
	if err != nil {
		h.utilHandler.SendError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	err = h.svc.ValidateTicket(req.TicketID, busData.RouteId, busData.RegistrationNumber)
	if err != nil {
		h.utilHandler.SendError(w, "Validation failed", http.StatusBadRequest)
		return
	}

	h.utilHandler.SendData(w, "Ticket validated successfully", http.StatusOK)
}
