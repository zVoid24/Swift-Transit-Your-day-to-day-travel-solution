package ticket

import (
	"net/http"
)

func (h *Handler) GetTickets(w http.ResponseWriter, r *http.Request) {
	// Extract user ID from context
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

	tickets, err := h.svc.GetByUserID(userId)
	if err != nil {
		h.utilHandler.SendError(w, "Failed to fetch tickets", http.StatusInternalServerError)
		return
	}

	h.utilHandler.SendData(w, tickets, http.StatusOK)
}
