package domain

import (
	"database/sql/driver"
	"encoding/json"
	"errors"
)

type Polygon struct {
	Type        string        `json:"type"`
	Coordinates [][][]float64 `json:"coordinates"`
}

func (p *Polygon) Scan(value interface{}) error {
	if value == nil {
		return nil
	}
	var data []byte
	switch v := value.(type) {
	case []byte:
		data = v
	case string:
		if v == "" {
			return nil
		}
		data = []byte(v)
	default:
		return errors.New("type assertion failed")
	}
	return json.Unmarshal(data, p)
}

func (p Polygon) Value() (driver.Value, error) {
	b, err := json.Marshal(p)
	return string(b), err
}

type Stop struct {
	Id       int64    `json:"id" db:"id"`
	RouteId  int64    `json:"route_id" db:"route_id"`
	Name     string   `json:"name" db:"name"`
	Order    int      `json:"order" db:"stop_order"`
	Lon      float64  `json:"lon" db:"lon"`
	Lat      float64  `json:"lat" db:"lat"`
	AreaGeom *Polygon `json:"area_geom" db:"area_geom"`
}
