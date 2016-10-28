DROP FUNCTION IF EXISTS london_streetwidth.SW_intersect_pg();
DROP TABLE IF EXISTS london_streetwidth.iterations CASCADE;
CREATE TABLE london_streetwidth.iterations (i float);
INSERT INTO london_streetwidth.iterations VALUES (3);
INSERT INTO london_streetwidth.iterations VALUES (4);
INSERT INTO london_streetwidth.iterations VALUES (5);
INSERT INTO london_streetwidth.iterations VALUES (6);

CREATE OR REPLACE FUNCTION london_streetwidth.SW_intersect_pg() 
	RETURNS TABLE (gid integer, w_avg_h real) 
	AS $BODY$
		DECLARE 
			i float;
		BEGIN
			FOR i IN SELECT * FROM london_streetwidth.iterations 
			LOOP
			RETURN QUERY 
			WITH lines AS (select t1.gid, st_offsetcurve(st_linemerge(t1.geom), i) as geom  from london_streetwidth.road_split t1) 
			SELECT lines.gid, SUM(buildings.rel_h * buildings.area)/SUM(buildings.area) w_avg_h 
				FROM lines 
				JOIN london_streetwidth.buildings AS buildings 
				ON ST_Within(ST_Centroid(lines.geom), buildings.wkb_geometry) 
				GROUP BY lines.gid;
			END LOOP;
			RETURN;
		END
	$BODY$ 
	LANGUAGE plpgsql 
	STABLE;

SELECT * FROM london_streetwidth.SW_Intersect_pg(2)