package route

import (
	"fmt"
	"net/http"
)

func (h *Handler) SearchStops(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("SearchStops called. URL: %s\n", r.URL.String())
	query := r.URL.Query().Get("q")
	fmt.Printf("Query param 'q': '%s'\n", query)

	if query == "" {
		http.Error(w, "query parameter 'q' is required", http.StatusBadRequest)
		return
	}

	stops, err := h.svc.SearchStops(query)
	if err != nil {
		h.utilHandler.SendError(w, "Failed to search stops", http.StatusInternalServerError)
		return
	}

	h.utilHandler.SendData(w, stops, http.StatusOK)
}
