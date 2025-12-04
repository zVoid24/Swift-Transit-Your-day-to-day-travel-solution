package ticket

import (
	"fmt"
	"net/http"
	"strconv"
)

func (h *Handler) PaymentSuccess(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		h.utilHandler.SendError(w, map[string]string{"error": "missing id parameter"}, http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.utilHandler.SendError(w, map[string]string{"error": "invalid id parameter"}, http.StatusBadRequest)
		return
	}

	err = h.svc.UpdatePaymentStatus(int64(id))
	if err != nil {
		h.utilHandler.SendError(w, map[string]string{"error": err.Error()}, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, `
		<html>
			<head>
				<title>Payment Successful</title>
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<style>
					body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
					.icon { color: green; font-size: 48px; }
				</style>
			</head>
			<body>
				<div class="icon">✓</div>
				<h1>Payment Successful</h1>
				<p>Your payment has been processed successfully.</p>
				<p>You can close this window now.</p>
			</body>
		</html>
	`)
}
