-- +migrate Up
ALTER TABLE stops ADD COLUMN IF NOT EXISTS area_geom geometry(Polygon, 4326);

-- +migrate Down
ALTER TABLE stops DROP COLUMN IF EXISTS area_geom;
