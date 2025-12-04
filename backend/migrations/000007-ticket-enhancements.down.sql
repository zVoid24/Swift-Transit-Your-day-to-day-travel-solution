-- +migrate Down
ALTER TABLE tickets
    DROP COLUMN IF EXISTS batch_id,
    DROP COLUMN IF EXISTS payment_method,
    DROP COLUMN IF EXISTS payment_reference,
    DROP COLUMN IF EXISTS payment_used,
    DROP COLUMN IF EXISTS payment_status,
    DROP COLUMN IF EXISTS cancelled_at;
