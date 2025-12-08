package bus_owner

import "net/http"

func (h *Handler) GetRoutes(w http.ResponseWriter, r *http.Request) {
	routes, err := h.svc.GetRoutes()
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusInternalServerError)
		return
	}

	h.utilHandler.SendData(w, routes, http.StatusOK)
}
