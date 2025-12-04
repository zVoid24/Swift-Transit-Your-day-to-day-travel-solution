package transaction

import (
	"swift_transit/model"
	"swift_transit/repo"
)

type Service interface {
	GetTransactions(userID int) ([]model.Transaction, error)
}

type service struct {
	repo *repo.TransactionRepo
}

func NewService(repo *repo.TransactionRepo) Service {
	return &service{
		repo: repo,
	}
}

func (s *service) GetTransactions(userID int) ([]model.Transaction, error) {
	return s.repo.GetByUserID(userID)
}
