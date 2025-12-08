-- +migrate Up
ALTER TABLE tickets
    ADD COLUMN IF NOT EXISTS registration_number VARCHAR(255);