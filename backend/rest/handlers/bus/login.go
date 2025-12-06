package bus

import (
	"encoding/json"
	"net/http"
)

type LoginRequest struct {
	RegistrationNumber string `json:"registration_number"`
	Password           string `json:"password"`
}

func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	bus, err := h.svc.Login(req.RegistrationNumber, req.Password)
	if err != nil {
		h.utilHandler.SendError(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	busData := BusAuthData{
		Id:                 bus.Id,
		RegistrationNumber: bus.RegistrationNumber,
		RouteId:            bus.RouteId,
	}

	token, err := h.utilHandler.CreateJWT(busData)
	if err != nil {
		h.utilHandler.SendError(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	resp := AuthResponse{
		Token: token,
		Bus:   busData,
	}

	h.utilHandler.SendData(w, resp, http.StatusOK)
}
