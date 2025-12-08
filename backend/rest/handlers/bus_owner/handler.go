package bus_owner

import (
	"swift_transit/bus_owner"
	"swift_transit/rest/middlewares"
	"swift_transit/utils"
)

type Handler struct {
	svc               bus_owner.Service
	middlewareHandler *middlewares.Handler
	mngr              *middlewares.Manager
	utilHandler       *utils.Handler
}

func NewHandler(svc bus_owner.Service, middlewareHandler *middlewares.Handler, mngr *middlewares.Manager, utilHandler *utils.Handler) *Handler {
	return &Handler{
		svc:               svc,
		middlewareHandler: middlewareHandler,
		mngr:              mngr,
		utilHandler:       utilHandler,
	}
}
