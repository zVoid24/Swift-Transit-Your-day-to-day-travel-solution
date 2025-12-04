-- +migrate Up
ALTER TABLE transactions ADD COLUMN payment_method VARCHAR(50);

-- +migrate Down
ALTER TABLE transactions DROP COLUMN payment_method;
