DROP FUNCTION IF EXISTS london_streetwidth.SW_Intersect(off_set float);
CREATE OR REPLACE FUNCTION london_streetwidth.SW_Intersect(off_set float)
	RETURNS TABLE (gid integer, w_avg_h real)
	AS 
	'WITH lines AS (select gid, st_offsetcurve(st_linemerge(geom), off_set) as geom  from london_streetwidth.road_split) 
		SELECT lines.gid, SUM(buildings.rel_h * buildings.area)/SUM(buildings.area) w_avg_h 
			FROM lines 
			JOIN london_streetwidth.buildings AS buildings 
			ON ST_Within(ST_Centroid(lines.geom), buildings.wkb_geometry) 
			GROUP BY lines.gid;'
	LANGUAGE SQL 
	STABLE 
	RETURNS NULL ON NULL INPUT;

SELECT * FROM london_streetwidth.SW_Intersect(2);