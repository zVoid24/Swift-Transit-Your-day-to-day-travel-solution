-- +migrate Down
ALTER TABLE tickets
    DROP COLUMN IF EXISTS registration_number;