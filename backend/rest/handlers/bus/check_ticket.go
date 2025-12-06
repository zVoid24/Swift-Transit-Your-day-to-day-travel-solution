package bus

import (
	"encoding/json"
	"net/http"
	"swift_transit/ticket"
)

func (h *Handler) CheckTicket(w http.ResponseWriter, r *http.Request) {
	var req ticket.CheckTicketRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Basic validation
	if req.QRCode == "" || req.RouteID == 0 || req.CurrentStoppage.Name == "" {
		http.Error(w, "Missing required fields", http.StatusBadRequest)
		return
	}

	result, err := h.svc.CheckTicket(req)
	if err != nil {
		// Differentiate errors if needed (e.g., 404 for not found, 409 for already used)
		// For now, 400 is generally safe for "invalid ticket"
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
