package transaction

import (
	"net/http"
	"swift_transit/rest/middlewares"
	"swift_transit/transaction"
	"swift_transit/utils"
)

type Handler struct {
	svc               transaction.Service
	middlewareHandler *middlewares.Handler
	mngr              *middlewares.Manager
	utilHandler       *utils.Handler
}

func NewHandler(svc transaction.Service, middlewareHandler *middlewares.Handler, mngr *middlewares.Manager, utilHandler *utils.Handler) *Handler {
	return &Handler{
		svc:               svc,
		middlewareHandler: middlewareHandler,
		mngr:              mngr,
		utilHandler:       utilHandler,
	}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux) {
	mux.Handle("GET /transactions", h.middlewareHandler.Authenticate(http.HandlerFunc(h.GetTransactions)))
	mux.Handle("POST /wallet/recharge", h.middlewareHandler.Authenticate(http.HandlerFunc(h.InitiateRecharge)))
	mux.Handle("/wallet/recharge/success", http.HandlerFunc(h.RechargeSuccess))
	mux.Handle("/wallet/recharge/fail", http.HandlerFunc(h.RechargeFail))
	mux.Handle("/wallet/recharge/cancel", http.HandlerFunc(h.RechargeCancel))
}
