package user

import (
	"encoding/json"
	"net/http"
)

type updateProfileRequest struct {
	Name   string `json:"name"`
	Email  string `json:"email"`
	Mobile string `json:"mobile"`
}

type changePasswordRequest struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}

func (h *Handler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	var req updateProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	userData := h.utilHandler.GetUserFromContext(r.Context())
	if userData == nil {
		h.utilHandler.SendError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	userMap, ok := userData.(map[string]interface{})
	if !ok {
		h.utilHandler.SendError(w, "Invalid user data", http.StatusUnauthorized)
		return
	}

	userIDFloat, ok := userMap["id"].(float64)
	if !ok {
		h.utilHandler.SendError(w, "Invalid user ID", http.StatusUnauthorized)
		return
	}

	updated, err := h.svc.UpdateProfile(int64(userIDFloat), req.Name, req.Email, req.Mobile)
	if err != nil {
		h.utilHandler.SendError(w, err.Error(), http.StatusBadRequest)
		return
	}

	h.utilHandler.SendData(w, updated, http.StatusOK)
}

func (h *Handler) ChangePassword(w http.ResponseWriter, r *http.Request) {
	var req changePasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.utilHandler.SendError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	userData := h.utilHandler.GetUserFromContext(r.Context())
	if userData == nil {
		h.utilHandler.SendError(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	userMap, ok := userData.(map[string]interface{})
	if !ok {
		h.utilHandler.SendError(w, "Invalid user data", http.StatusUnauthorized)
		return
	}

	userIDFloat, ok := userMap["id"].(float64)
	if !ok {
		h.utilHandler.SendError(w, "Invalid user ID", http.StatusUnauthorized)
		return
	}

	if req.NewPassword == "" {
		h.utilHandler.SendError(w, "New password is required", http.StatusBadRequest)
		return
	}

	if err := h.svc.ChangePassword(int64(userIDFloat), req.CurrentPassword, req.NewPassword); err != nil {
		status := http.StatusInternalServerError
		if err.Error() == "current password is incorrect" {
			status = http.StatusBadRequest
		}
		h.utilHandler.SendError(w, err.Error(), status)
		return
	}

	h.utilHandler.SendData(w, map[string]string{"message": "Password updated successfully"}, http.StatusOK)
}
