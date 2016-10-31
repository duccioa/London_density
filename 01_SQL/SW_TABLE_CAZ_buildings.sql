DROP TABLE IF EXISTS london_streetwidth.caz_buildings CASCADE;
CREATE TABLE london_streetwidth.caz_buildings AS 
	SELECT t1.ogc_fid, t1.wkb_geometry AS geom, t1.rel_h, t1.area FROM london_buildings.shapes t1, london.caz t2
	WHERE ST_Intersects(t1.wkb_geometry, t2.geom);
ALTER TABLE london_streetwidth.caz_buildings 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX caz_buildings_sp_idx
  ON london_streetwidth.caz_buildings
  USING gist
  (geom);