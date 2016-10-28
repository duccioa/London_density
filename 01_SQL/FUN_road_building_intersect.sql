-- Create offset from a line
-- SELECT gid, ST_OffsetCurve(ST_LineMerge(geom), -2) AS geom FROM london_streetwidth.road_split
CREATE OR REPLACE FUNCTION
	road_building_intersect(i integer)
WITH lines AS (select gid, st_offsetcurve(st_linemerge(geom), -0.1) as geom  from london_streetwidth.road_split) 
	SELECT lines.gid, SUM(buildings.rel_h * buildings.area)/SUM(buildings.area) w_avg_h 
		FROM lines 
		JOIN london_streetwidth.buildings AS buildings 
		ON ST_Within(ST_Centroid(lines.geom), buildings.wkb_geometry) 
		GROUP BY lines.gid
