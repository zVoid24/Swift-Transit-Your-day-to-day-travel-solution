package transaction

import (
	"net/http"
)

func (h *Handler) GetTransactions(w http.ResponseWriter, r *http.Request) {
	userData := h.utilHandler.GetUserFromContext(r.Context())
	if userData == nil {
		h.utilHandler.SendError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	// Assuming userData is a map[string]interface{} from JSON unmarshal
	userMap, ok := userData.(map[string]interface{})
	if !ok {
		h.utilHandler.SendError(w, "Invalid user data", http.StatusUnauthorized)
		return
	}

	userIDFloat, ok := userMap["id"].(float64) // JSON numbers are floats
	if !ok {
		h.utilHandler.SendError(w, "Invalid user ID", http.StatusUnauthorized)
		return
	}
	userID := int(userIDFloat)

	transactions, err := h.svc.GetTransactions(userID)
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusInternalServerError)
		return
	}

	h.utilHandler.SendData(w, transactions, http.StatusOK)
}
