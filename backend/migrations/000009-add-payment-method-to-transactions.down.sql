-- +migrate Down
ALTER TABLE transactions DROP COLUMN payment_method;
