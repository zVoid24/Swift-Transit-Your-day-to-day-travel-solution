package model

import "time"

type Transaction struct {
	ID            int       `json:"id" db:"id"`
	UserID        int       `json:"user_id" db:"user_id"`
	Amount        float64   `json:"amount" db:"amount"`
	Type          string    `json:"type" db:"type"` // credit, debit, purchase, refund
	Description   string    `json:"description" db:"description"`
	PaymentMethod string    `json:"payment_method" db:"payment_method"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}
