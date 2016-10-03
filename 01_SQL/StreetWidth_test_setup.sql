-- Create schema
CREATE SCHEMA london_streetwidth 
	AUTHORIZATION postgres;
-- Road table
CREATE TABLE london_streetwidth.roads AS (
	SELECT * FROM london_itn_topology.edge t1 
	WHERE ST_Within(st_centroid(t1.geom), 
		ST_Buffer(ST_GeomFromText('POINT(534418 184360)', 27700) , 400)
		)
	);
ALTER TABLE london_streetwidth.roads 
	ADD PRIMARY KEY (edge_id);
CREATE INDEX lnd_roads_sp_idx 
	ON london_streetwidth.roads 
	USING gist 
	(geom);
-- Building table
CREATE TABLE london_streetwidth.buildings AS (
	SELECT * FROM london_buildings.shapes t1 
	WHERE ST_Within(t1.geom_centroids, 
		ST_Buffer(ST_GeomFromText('POINT(534418 184360)', 27700) , 400)
		)
	);
ALTER TABLE london_streetwidth.buildings 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX lnd_buildings_sp_idx 
	ON london_streetwidth.buildings 
	USING gist 
	(wkb_geometry);
CREATE INDEX lnd_buildings_centroids_sp_idx 
	ON london_streetwidth.buildings 
	USING gist 
	(geom_centroids);