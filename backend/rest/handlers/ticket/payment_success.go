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
					body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; padding: 40px 20px; background-color: #f4f7f6; }
					.container { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); max-width: 400px; margin: 0 auto; }
					.icon { color: #2ecc71; font-size: 64px; margin-bottom: 20px; }
					h1 { color: #2c3e50; margin-bottom: 10px; font-size: 24px; }
					p { color: #7f8c8d; margin-bottom: 30px; font-size: 16px; line-height: 1.5; }
					.btn { display: inline-block; background-color: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: 600; transition: background 0.3s; }
					.btn:hover { background-color: #2980b9; }
				</style>
			</head>
			<body>
				<div class="container">
					<div class="icon">✓</div>
					<h1>Payment Successful</h1>
					<p>Your payment has been processed successfully.<br>You can now download your ticket.</p>
					<a href="/ticket/download?id=%d" class="btn">Download Ticket</a>
					<p style="margin-top: 20px; font-size: 14px; color: #95a5a6;">You can close this window now.</p>
				</div>
			</body>
		</html>
	`, id)
}
