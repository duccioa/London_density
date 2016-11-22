--- Create the intersect function ----
DROP FUNCTION IF EXISTS london_streetwidth.SW_intersect_gid(text,text,text,integer);
CREATE OR REPLACE FUNCTION london_streetwidth.SW_intersect_gid(road_table text, building_table text, iter_table text, road_gid integer) 
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
			EXECUTE format('WITH lines AS (SELECT t1.gid, ST_OffsetCurve((ST_dump(ST_LineMerge(t1.geom))).geom, %2$s) AS geom  FROM %1$s AS t1 WHERE t1.gid = %5$s) 
			SELECT lines.gid, SUM(buildings.rel_h * buildings.area)/SUM(buildings.area) AS w_avg_h,  %4$s AS side, CAST(%2$s AS float) AS iteration 
				FROM lines 
				JOIN %3$s AS buildings 
				ON ST_Within(lines.geom, buildings.wkb_geometry) 
				GROUP BY lines.gid', road_table, i, building_table, side, road_gid);
			END LOOP;
			RETURN;
		END
	$$ 
	LANGUAGE plpgsql 
	STABLE;

--- Create the intersect function ----
DROP FUNCTION IF EXISTS london_streetwidth.SW_offset(text,text,integer);
CREATE OR REPLACE FUNCTION london_streetwidth.SW_offset(road_table text, iter_table text, road_gid integer) 
	RETURNS TABLE (gid integer, geom geometry, iteration integer) 
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
			EXECUTE format('SELECT t1.gid, ST_OffsetCurve((ST_dump(ST_LineMerge(t1.geom))).geom, %2$s) AS geom, i as offset  FROM %1$s AS t1 WHERE t1.gid = %3$s', 
			road_table, i, road_gid);
			END LOOP;
			RETURN;
		END
	$$ 
	LANGUAGE plpgsql 
	STABLE;


