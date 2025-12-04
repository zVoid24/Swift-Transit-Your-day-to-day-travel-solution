package domain

type Ticket struct {
	Id               int64   `json:"id" db:"id"`
	UserId           int64   `json:"user_id" db:"user_id"`
	RouteId          int64   `json:"route_id" db:"route_id"`
	BusName          string  `json:"bus_name" db:"bus_name"`
	StartDestination string  `json:"start_destination" db:"start_destination"`
	EndDestination   string  `json:"end_destination" db:"end_destination"`
	Fare             float64 `json:"fare" db:"fare"`
	PaidStatus       bool    `json:"paid_status" db:"paid_status"`
	Checked          bool    `json:"checked" db:"checked"`
	QRCode           string  `json:"qr_code" db:"qr_code"`
	CreatedAt        string  `json:"created_at" db:"created_at"`
	BatchID          string  `json:"batch_id" db:"batch_id"`
	PaymentMethod    string  `json:"payment_method" db:"payment_method"`
	PaymentReference string  `json:"payment_reference" db:"payment_reference"`
	PaymentUsed      bool    `json:"payment_used" db:"payment_used"`
	PaymentStatus    string  `json:"payment_status" db:"payment_status"`
	CancelledAt      *string `json:"cancelled_at,omitempty" db:"cancelled_at"`
}
