package ticket

import (
	"net/http"
	"strconv"
)

func (h *Handler) GetTicketStatus(w http.ResponseWriter, r *http.Request) {
	// Check if checking by ticket ID (payment status)
	idStr := r.URL.Query().Get("id")
	if idStr != "" {
		id, err := strconv.Atoi(idStr)
		if err != nil {
			h.utilHandler.SendError(w, "invalid id parameter", http.StatusBadRequest)
			return
		}
		status, err := h.svc.GetPaymentStatus(int64(id))
		if err != nil {
			h.utilHandler.SendError(w, err.Error(), http.StatusInternalServerError)
			return
		}
		h.utilHandler.SendData(w, map[string]string{"status": status}, http.StatusOK)
		return
	}

	trackingID := r.URL.Query().Get("tracking_id")
	if trackingID == "" {
		h.utilHandler.SendError(w, "tracking_id or id is required", http.StatusBadRequest)
		return
	}

	res, err := h.svc.GetTicketStatus(trackingID)
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusNotFound)
		return
	}

	h.utilHandler.SendData(w, res, http.StatusOK)
}
