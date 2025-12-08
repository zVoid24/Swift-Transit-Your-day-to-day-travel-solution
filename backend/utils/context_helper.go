package utils

import (
	"context"
	"fmt"
)

type contextKey string

const UserContextKey = contextKey("user")

func (h *Handler) AddToContext(ctx context.Context, userData any) context.Context {
	fmt.Println(userData)
	return context.WithValue(ctx, UserContextKey, userData)
}

func (h *Handler) GetUserFromContext(ctx context.Context) any {
	return ctx.Value(UserContextKey)
}

func (h *Handler) GetUserIDFromContext(ctx context.Context) int64 {
	userData := h.GetUserFromContext(ctx)
	fmt.Println(userData)
	if userData == nil {
		fmt.Println("GetUserIDFromContext: userData is nil")
		return 0
	}

	fmt.Printf("GetUserIDFromContext: type=%T, value=%+v\n", userData, userData)

	switch v := userData.(type) {
	case float64:
		return int64(v)
	case int64:
		return v
	case int:
		return int64(v)
	case map[string]interface{}:
		if id, ok := v["id"].(float64); ok {
			return int64(id)
		}
		if id, ok := v["id"].(int64); ok {
			return id
		}
		fmt.Println("GetUserIDFromContext: map does not contain id or id is not a number")
	}
	return 0
}
