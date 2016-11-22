---------------- ONDON STREET WIDTH --------------------
-- This set of SQL queries produces a table with the street width of London CAZ based on the Integrated Trasportation Network, 
-- the topographic layer of the Mastermap and the building height of the same database  

---- Create the schema ----
DROP SCHEMA IF EXISTS london_streetwidth CASCADE;
CREATE SCHEMA london_streetwidth
	AUTHORIZATION postgres;
	
--- Create the iteration table ----
DROP TABLE IF EXISTS london_streetwidth.iterations CASCADE;
CREATE TABLE london_streetwidth.iterations (i float);
INSERT INTO london_streetwidth.iterations VALUES (0);
INSERT INTO london_streetwidth.iterations VALUES (1);
INSERT INTO london_streetwidth.iterations VALUES (-1);
INSERT INTO london_streetwidth.iterations VALUES (2);
INSERT INTO london_streetwidth.iterations VALUES (3);
INSERT INTO london_streetwidth.iterations VALUES (4);
INSERT INTO london_streetwidth.iterations VALUES (5);
INSERT INTO london_streetwidth.iterations VALUES (6);
INSERT INTO london_streetwidth.iterations VALUES (7);
INSERT INTO london_streetwidth.iterations VALUES (8);
INSERT INTO london_streetwidth.iterations VALUES (9);
INSERT INTO london_streetwidth.iterations VALUES (10);
INSERT INTO london_streetwidth.iterations VALUES (11);
INSERT INTO london_streetwidth.iterations VALUES (12);
INSERT INTO london_streetwidth.iterations VALUES (16);
INSERT INTO london_streetwidth.iterations VALUES (20);
INSERT INTO london_streetwidth.iterations VALUES (24);
INSERT INTO london_streetwidth.iterations VALUES (30);
INSERT INTO london_streetwidth.iterations VALUES (-2);
INSERT INTO london_streetwidth.iterations VALUES (-3);
INSERT INTO london_streetwidth.iterations VALUES (-4);
INSERT INTO london_streetwidth.iterations VALUES (-5);
INSERT INTO london_streetwidth.iterations VALUES (-6);
INSERT INTO london_streetwidth.iterations VALUES (-7);
INSERT INTO london_streetwidth.iterations VALUES (-8);
INSERT INTO london_streetwidth.iterations VALUES (-9);
INSERT INTO london_streetwidth.iterations VALUES (-10);
INSERT INTO london_streetwidth.iterations VALUES (-11);
INSERT INTO london_streetwidth.iterations VALUES (-12);
INSERT INTO london_streetwidth.iterations VALUES (-16);
INSERT INTO london_streetwidth.iterations VALUES (-20);
INSERT INTO london_streetwidth.iterations VALUES (-24);
INSERT INTO london_streetwidth.iterations VALUES (-30);

--- Create the intersect function ----
DROP FUNCTION IF EXISTS london_streetwidth.SW_intersect_pg(text,text,text);
CREATE OR REPLACE FUNCTION london_streetwidth.SW_intersect_pg(road_table text, building_table text, iter_table text) 
	RETURNS TABLE (gid integer, w_avg_h real, side boolean,iteration float) 
	AS $$
		DECLARE 
			i float;
			side text;
		BEGIN
			FOR i IN EXECUTE format('SELECT * FROM %s',iter_table) 
			LOOP
			IF i >= 0 THEN 
				side := True;
			ELSE 
				side := False;
			END IF;
			RETURN QUERY 
			EXECUTE format('WITH lines AS (SELECT t1.gid, ST_OffsetCurve((ST_dump(ST_LineMerge(t1.geom))).geom, %2$s) AS geom  FROM %1$s AS t1) 
			SELECT lines.gid, SUM(buildings.rel_h * buildings.area)/SUM(buildings.area) AS w_avg_h,  %4$s AS side, CAST(%2$s AS float) AS iteration 
				FROM lines 
				JOIN %3$s AS buildings 
				ON ST_Within(ST_centroid(lines.geom), buildings.wkb_geometry) 
				GROUP BY lines.gid', road_table, i, building_table, side);
			END LOOP;
			RETURN;
		END
	$$ 
	LANGUAGE plpgsql 
	STABLE;

---- Create the subsets of the ITN table and buildings ----
-- Roads
DROP TABLE IF EXISTS london_streetwidth.caz_roads CASCADE;
CREATE TABLE london_streetwidth.caz_roads AS 
	SELECT t1.edge_id, t1.geom FROM london_itn_topology.edge t1, london.caz t2
	WHERE ST_Intersects(t1.geom, t2.geom);
ALTER TABLE london_streetwidth.caz_roads 
	ADD PRIMARY KEY (edge_id);
CREATE INDEX caz_roads_sp_idx2
  ON london_streetwidth.caz_roads
  USING gist
  (geom);
-- Buildings
DROP TABLE IF EXISTS london_streetwidth.caz_buildings CASCADE;
CREATE TABLE london_streetwidth.caz_buildings AS 
	SELECT t1.ogc_fid, t1.wkb_geometry, t1.rel_h, t1.area FROM london_buildings.shapes t1, london.caz t2
	WHERE ST_Intersects(t1.wkb_geometry, t2.geom);
ALTER TABLE london_streetwidth.caz_buildings 
	ADD PRIMARY KEY (ogc_fid);
CREATE INDEX caz_buildings_sp_idx
  ON london_streetwidth.caz_buildings
  USING gist
  (wkb_geometry);

---- EXECUTE OUTSIDE SQL ----

---- Split the road network into segments ----
-- Run SplitRoadGeometry.R

---- Copy the shp file of the split geometry to the database ----
-- In terminal:
-- cd /Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity/05_Data/StreetWidth
-- shp2pgsql -I -s 27700 caz_road_geom_split.shp london_streetwidth.caz_road_split -expolodecollections | psql -d msc -U postgres -W

-----------------------------

---- Run the intersection ----
DROP TABLE IF EXISTS london_streetwidth.intersect_results CASCADE;
CREATE TABLE london_streetwidth.intersect_results AS 
	SELECT * 
	FROM london_streetwidth.SW_intersect_pg('london_streetwidth.caz_road_split',
						'london_streetwidth.caz_buildings',
						'london_streetwidth.iterations');
ALTER TABLE london_streetwidth.intersect_results 
	ADD COLUMN row_id SERIAL PRIMARY KEY;


---- Import results in database ----
DROP TABLE IF EXISTS london_streetwidth.width CASCADE;
CREATE TABLE london_streetwidth.width
(
  gid integer NOT NULL,
  w_avg_r real,
  w_avg_l real,
  width_r integer,
  width_l integer,
  width integer,
  c_ration real,
  CONSTRAINT width_pkey PRIMARY KEY (gid)
)
WITH (
OIDS=FALSE
);
ALTER TABLE london_streetwidth.width
OWNER TO postgres;


---- EXECUTE OUTSIDE SQL ----

---- Data cleaning ----
-- Run CleanIntersectData.R
-- In terminal:
-- \copy london_streetwidth.width from '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity/05_Data/london_streetwidth_width.csv' CSV HEADER;
-----------------------------

---- Create table with valid and null results ----
DROP TABLE IF EXISTS london_streetwidth.res_table CASCADE;
CREATE TABLE london_streetwidth.res_table AS
	SELECT t1.gid, t2.w_avg_r, t2.w_avg_l, t2.width_r, t2.width_l, t2.width 
		FROM london_streetwidth.caz_road_split t1 
		LEFT OUTER JOIN london_streetwidth.width t2 
		ON t1.gid = t2.gid;
ALTER TABLE london_streetwidth.res_table 
	ADD PRIMARY KEY (gid);
UPDATE london_streetwidth.res_table  SET w_avg_r = 0, w_avg_l = 0, width_r = 1000, width_l = 1000, width = 1000000000 
	WHERE width IS NULL;
select * from london_streetwidth.res_table

---- Select the geometry and the data ----
SELECT t1.gid, t1.id, t1.geom, t2.w_avg_r, t2.w_avg_l, t2.width_r, t2.width_l, t2.width 
	FROM london_streetwidth.caz_road_split t1 
	JOIN london_streetwidth.res_table t2
	ON t1.gid = t2.gid;