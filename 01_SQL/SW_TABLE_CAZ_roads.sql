DROP TABLE IF EXISTS london_streetwidth.caz_roads CASCADE;
CREATE TABLE london_streetwidth.caz_roads AS 
	SELECT t1.edge_id, t1.geom FROM london_itn_topology.edge t1, london.caz t2
	WHERE ST_Intersects(t1.geom, t2.geom);
ALTER TABLE london_streetwidth.caz_roads 
	ADD PRIMARY KEY (edge_id);
CREATE INDEX caz_roads_sp_idx
  ON london_streetwidth.caz_roads
  USING gist
  (geom);