package transaction

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type rechargeRequest struct {
	Amount float64 `json:"amount"`
}

type rechargeResponse struct {
	GatewayURL string `json:"gateway_url"`
	TranID     string `json:"tran_id"`
}

func (h *Handler) InitiateRecharge(w http.ResponseWriter, r *http.Request) {
	var req rechargeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	userData := h.utilHandler.GetUserFromContext(r.Context())
	if userData == nil {
		h.utilHandler.SendError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	userMap, ok := userData.(map[string]interface{})
	if !ok {
		h.utilHandler.SendError(w, "Invalid user data", http.StatusUnauthorized)
		return
	}

	userIDFloat, ok := userMap["id"].(float64)
	if !ok {
		h.utilHandler.SendError(w, "Invalid user ID", http.StatusUnauthorized)
		return
	}

	gatewayURL, tranID, err := h.svc.InitRecharge(r.Context(), int64(userIDFloat), req.Amount)
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusBadRequest)
		return
	}

	h.utilHandler.SendData(w, rechargeResponse{GatewayURL: gatewayURL, TranID: tranID}, http.StatusOK)
}

func (h *Handler) RechargeSuccess(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		h.utilHandler.SendError(w, "Invalid request", http.StatusBadRequest)
		return
	}

	tranID := r.FormValue("tran_id")
	if tranID == "" {
		tranID = r.URL.Query().Get("tran_id")
	}

	valID := r.FormValue("val_id")
	if valID == "" {
		valID = r.URL.Query().Get("val_id")
	}

	if tranID == "" || valID == "" {
		h.utilHandler.SendError(w, "Missing transaction reference", http.StatusBadRequest)
		return
	}

	if err := h.svc.CompleteRecharge(r.Context(), tranID, valID); err != nil {
		h.renderRechargeResult(w, false, err.Error())
		return
	}

	h.renderRechargeResult(w, true, "Recharge successful")
}

func (h *Handler) RechargeFail(w http.ResponseWriter, r *http.Request) {
	tranID := r.URL.Query().Get("tran_id")
	if tranID != "" {
		_ = h.svc.CancelRecharge(r.Context(), tranID)
	}
	h.renderRechargeResult(w, false, "Payment failed. Please try again.")
}

func (h *Handler) RechargeCancel(w http.ResponseWriter, r *http.Request) {
	tranID := r.URL.Query().Get("tran_id")
	if tranID != "" {
		_ = h.svc.CancelRecharge(r.Context(), tranID)
	}
	h.renderRechargeResult(w, false, "Payment cancelled")
}

func (h *Handler) renderRechargeResult(w http.ResponseWriter, success bool, message string) {
	status := "failed"
	icon := "✕"
	color := "#e74c3c"
	if success {
		status = "success"
		icon = "✓"
		color = "#27ae60"
	}

	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, `
        <html>
            <head>
                <title>Recharge %s</title>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; padding: 40px 20px; background-color: #f4f7f6; }
                    .container { background: white; padding: 36px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); max-width: 420px; margin: 0 auto; }
                    .icon { color: %s; font-size: 64px; margin-bottom: 16px; }
                    h1 { color: #2c3e50; margin-bottom: 10px; font-size: 24px; }
                    p { color: #7f8c8d; margin-bottom: 20px; font-size: 16px; line-height: 1.5; }
                    .btn { display: inline-block; background-color: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: 600; transition: background 0.3s; }
                    .btn:hover { background-color: #2980b9; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="icon">%s</div>
                    <h1>Recharge %s</h1>
                    <p>%s</p>
                    <p style="margin-top: 12px; font-size: 14px; color: #95a5a6;">You can close this window now.</p>
                </div>
            </body>
        </html>
    `, status, color, icon, status, message)
}
