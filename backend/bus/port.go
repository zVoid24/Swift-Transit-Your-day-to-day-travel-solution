package bus

import (
	"swift_transit/domain"
	"swift_transit/ticket"
)

type Service interface {
	FindBus(start, end string) ([]domain.Bus, error)
	Login(regNum, password string) (*domain.BusCredential, error)
	Register(regNum, password string, routeId int64) (*domain.BusCredential, error)
	ValidateTicket(ticketID int64, routeID int64) error
	CheckTicket(req ticket.CheckTicketRequest) (map[string]interface{}, error)
}

type BusRepo interface {
	FindBus(start, end string) ([]domain.Bus, error)
	GetBusByRegistrationNumber(regNum string) (*domain.BusCredential, error)
	Create(busCred domain.BusCredential) (*domain.BusCredential, error)
}
