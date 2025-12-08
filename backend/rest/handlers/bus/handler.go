package bus

import (
	"swift_transit/location" // Added import for location package
	"swift_transit/rest/middlewares"
	"swift_transit/ticket"
	"swift_transit/utils"
)

type BusAuthData struct {
	Id                 int64          `json:"id"`
	RegistrationNumber string         `json:"registration_number"`
	RouteId            int64          `json:"route_id"`
	Variant            string         `json:"variant"`
	Variants           []RouteVariant `json:"variants,omitempty"`
}

type RouteVariant struct {
	Variant string `json:"variant"`
	RouteId int64  `json:"route_id"`
}

type AuthResponse struct {
	Token string      `json:"token"`
	Bus   BusAuthData `json:"bus"`
}

type Handler struct {
	svc               Service
	ticketService     ticket.Service
	middlewareHandler *middlewares.Handler
	mngr              *middlewares.Manager
	utilHandler       *utils.Handler
	hub               *location.Hub // Added Hub field
}

func NewHandler(svc Service, ticketService ticket.Service, middlewareHandler *middlewares.Handler, mngr *middlewares.Manager, utilHandler *utils.Handler, hub *location.Hub) *Handler {
	return &Handler{
		svc:               svc,
		ticketService:     ticketService,
		middlewareHandler: middlewareHandler,
		mngr:              mngr,
		utilHandler:       utilHandler,
		hub:               hub, // Initialized Hub field
	}
}

// BusFromContext is already defined in context.go
