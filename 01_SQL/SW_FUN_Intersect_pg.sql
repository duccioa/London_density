DROP FUNCTION IF EXISTS london_streetwidth.SW_intersect_pg();
CREATE OR REPLACE FUNCTION london_streetwidth.SW_intersect_pg() 
	RETURNS TABLE (gid integer, w_avg_h real, side boolean, iteration float) 
	AS $$
		DECLARE 
			i float;
			side boolean;
		BEGIN
			FOR i IN SELECT * FROM london_streetwidth.iterations 
			LOOP
			IF i >= 0 THEN 
				side := 1;
			ELSE 
				side := 0;
			END IF;
			RETURN QUERY 
			WITH lines AS (SELECT t1.gid, st_offsetcurve(st_linemerge(t1.geom), i) AS geom  FROM london_streetwidth.road_split t1) 
			SELECT lines.gid, SUM(buildings.rel_h * buildings.area)/SUM(buildings.area) w_avg_h, side AS side, i AS iteration 
				FROM lines 
				JOIN london_streetwidth.buildings AS buildings 
				ON ST_Within(ST_Centroid(lines.geom), buildings.wkb_geometry) 
				GROUP BY lines.gid;
			END LOOP;
			RETURN;
		END
	$$ 
	LANGUAGE plpgsql 
	STABLE;

SELECT * FROM london_streetwidth.SW_intersect_pg();