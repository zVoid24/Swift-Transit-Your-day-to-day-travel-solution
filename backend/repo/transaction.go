package repo

import (
	"database/sql"
	"swift_transit/model"
	"swift_transit/utils"

	"github.com/jmoiron/sqlx"
)

type TransactionRepo struct {
	db      *sqlx.DB
	handler *utils.Handler
}

func NewTransactionRepo(db *sqlx.DB, handler *utils.Handler) *TransactionRepo {
	return &TransactionRepo{
		db:      db,
		handler: handler,
	}
}

func (r *TransactionRepo) Create(t model.Transaction) error {
	query := `INSERT INTO transactions (user_id, amount, type, description, payment_method, created_at) VALUES (:user_id, :amount, :type, :description, :payment_method, :created_at)`
	_, err := r.db.NamedExec(query, t)
	return err
}

func (r *TransactionRepo) GetByUserID(userID int) ([]model.Transaction, error) {
	var transactions []model.Transaction
	query := `SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC`
	err := r.db.Select(&transactions, query, userID)
	if err == sql.ErrNoRows {
		return []model.Transaction{}, nil
	}
	return transactions, err
}
