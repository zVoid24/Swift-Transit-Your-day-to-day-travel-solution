package utils

import (
	"net/http"
	"strconv"
	"swift_transit/config"
)

type Handler struct {
	cnf *config.Config
}

func NewHandler(cnf *config.Config) *Handler {
	return &Handler{
		cnf: cnf,
	}
}

func (h *Handler) GetID(r *http.Request) int64 {
	idStr := r.PathValue("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		return 0
	}
	return id
}
