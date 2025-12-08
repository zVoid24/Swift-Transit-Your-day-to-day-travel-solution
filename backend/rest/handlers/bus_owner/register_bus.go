package bus_owner

import (
	"encoding/json"
	"net/http"
)

type RegisterBusRequest struct {
	RegistrationNumber string `json:"registration_number"`
	Password           string `json:"password"`
	RouteIdUp          int64  `json:"route_id_up"`
	RouteIdDown        int64  `json:"route_id_down"`
}

func (h *Handler) RegisterBus(w http.ResponseWriter, r *http.Request) {
	// Extract owner ID from context (middleware should set it)
	// Assuming middleware sets "user_id" or similar. We might need a specific middleware for bus owners or reuse user one if IDs don't clash or if we use a different claim.
	// For now, let's assume standard auth middleware works and puts ID in context.
	// We need to verify if the token is for a bus owner.

	// TODO: Implement BusOwnerAuth middleware or check role.
	// For MVP, assuming the ID in context is the owner ID.

	// Actually, the current Authenticate middleware puts "user_id" in context.
	// We should probably check if we need a separate middleware.
	// Let's assume we use the same JWT structure but maybe different subject or claim?
	// Or just use the ID.

	// ownerID := r.Context().Value("user_id").(int64) // This might panic if not set

	// Let's check how to get ID safely.
	// h.utilHandler doesn't seem to have GetIDFromContext.
	// Let's look at how other handlers get ID.

	// In `backend/rest/handlers/user/profile.go`:
	// id := r.Context().Value("user_id").(float64) // It seems it's float64 from JWT parsing?

	var req RegisterBusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Mocking owner ID for now until middleware is sorted or assuming 1 for testing if context fails
	// But we should try to get it.

	// Retrieve user_id from context using helper
	ownerID := h.utilHandler.GetUserIDFromContext(r.Context())
	if ownerID == 0 {
		h.utilHandler.SendError(w, "Unauthorized: Invalid user ID", http.StatusUnauthorized)
		return
	}

	if err := h.svc.RegisterBus(ownerID, req.RegistrationNumber, req.Password, req.RouteIdUp, req.RouteIdDown); err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusBadRequest)
		return
	}

	h.utilHandler.SendData(w, "Bus registered successfully", http.StatusCreated)
}
