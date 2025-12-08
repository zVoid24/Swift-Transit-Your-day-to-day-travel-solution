package bus_owner

import (
	"net/http"
)

func (h *Handler) GetBuses(w http.ResponseWriter, r *http.Request) {
	ownerID := h.utilHandler.GetUserIDFromContext(r.Context())
	if ownerID == 0 {
		h.utilHandler.SendError(w, "Unauthorized: Invalid user ID", http.StatusUnauthorized)
		return
	}

	buses, err := h.svc.GetBuses(ownerID)
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusInternalServerError)
		return
	}

	h.utilHandler.SendData(w, buses, http.StatusOK)
}
