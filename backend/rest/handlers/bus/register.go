package bus

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type RegisterRequest struct {
	RegistrationNumber string `json:"registration_number"`
	Password           string `json:"password"`
	RouteId            int64  `json:"route_id"`
}

func (h *Handler) Register(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if req.RegistrationNumber == "" || req.Password == "" || req.RouteId == 0 {
		h.utilHandler.SendError(w, "Registration Number, Password and Route ID are required", http.StatusBadRequest)
		return
	}

	busCred, err := h.svc.Register(req.RegistrationNumber, req.Password, req.RouteId)
	if err != nil {
		h.utilHandler.SendError(w, fmt.Sprintf("Failed to register bus: %s", err.Error()), http.StatusInternalServerError)
		return
	}

	busData := BusAuthData{
		Id:                 busCred.Id,
		RegistrationNumber: busCred.RegistrationNumber,
		RouteId:            busCred.RouteId,
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
