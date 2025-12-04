package ticket

import (
	"net/http"
	"strconv"
)

func (h *Handler) CancelTicket(w http.ResponseWriter, r *http.Request) {
	userData := h.utilHandler.GetUserFromContext(r.Context())
	if userData == nil {
		h.utilHandler.SendError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var userId int64
	switch v := userData.(type) {
	case float64:
		userId = int64(v)
	case map[string]interface{}:
		if id, ok := v["id"].(float64); ok {
			userId = int64(id)
		}
	}

	if userId == 0 {
		h.utilHandler.SendError(w, "Invalid user data in token", http.StatusUnauthorized)
		return
	}

	idStr := r.PathValue("id")
	ticketID, err := strconv.Atoi(idStr)
	if err != nil {
		h.utilHandler.SendError(w, "invalid ticket id", http.StatusBadRequest)
		return
	}

	refund, err := h.svc.CancelTicket(userId, int64(ticketID))
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusBadRequest)
		return
	}

	h.utilHandler.SendData(w, map[string]any{
		"message": "Ticket cancelled",
		"refund":  refund,
	}, http.StatusOK)
}
