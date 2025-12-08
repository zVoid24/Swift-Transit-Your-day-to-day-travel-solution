-- +migrate Down
ALTER TABLE bus_credentials DROP COLUMN IF EXISTS owner_id;
DROP TABLE IF EXISTS bus_owners;
