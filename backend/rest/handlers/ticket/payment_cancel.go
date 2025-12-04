package ticket

import (
	"net/http"
	"strconv"
)

func (h *Handler) PaymentCancel(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	if idStr != "" {
		if id, err := strconv.Atoi(idStr); err == nil {
			_, _ = h.svc.HandlePaymentResult(int64(id), "cancelled")
		}
	}

	h.utilHandler.SendError(w, map[string]string{
		"message": "Payment cancelled",
		"status":  "cancelled",
	}, http.StatusOK)
}
