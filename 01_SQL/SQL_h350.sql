---- Add columns with average height 3.5m ----
BEGIN;
alter table london_buildings.shapes 
	add column n_floors350 integer default 0;
UPDATE london_buildings.shapes AS s1 SET n_floors350 = s2.rel_h/3.5 FROM london_buildings.shapes s2 WHERE s1.ogc_fid = s2.ogc_fid;
COMMIT;
-- Spatial JOIN blocks-buildings
BEGIN;
DROP TABLE IF EXISTS support.block350h CASCADE;
CREATE TABLE support.block350h AS
	(
	SELECT a.block_id,
		SUM(b.area*b.n_floors350) AS total_floor_surface350,
		SUM(b.area*b.n_floors350)/a.area_block AS fsi350,
		SUM(b.area*b.n_floors350)/SUM(b.area) AS w_avg_nfloors350
	FROM london_blocks.blocks AS a 
	INNER JOIN london_buildings.shapes AS b 
	ON ST_Within(b.geom_centroids, a.wkb_geometry) 
	GROUP BY a.block_id
	);
ALTER TABLE support.block350h 
	ADD PRIMARY KEY (block_id);
ALTER TABLE support.block350h ALTER COLUMN block_id SET DATA TYPE text;
COMMIT;
SELECT t1.block_id,
	t1.geom_block,
	t1.area_block,
	t1.building_count,
	t1.total_footprint,
	t1.gsi,
	t1.total_floor_surface AS total_floor_surface_h300,
	t1.fsi AS fsi_h300,
	t1.w_avg_nfloors AS w_avg_nfloors_h300,
	t2.total_floor_surface350 AS total_floor_surface_h350,
	t2.fsi350 AS fsi_h350,
	t2.w_avg_nfloors350 AS w_avg_nfloors_h350,
	label AS label_h300,
	t1.caz 
	FROM london_index.block_cluster_labels AS t1 
	INNER JOIN support.block350h AS t2 
	ON (t1.block_id=t2.block_id); 	
-- Add PARK column
CREATE TABLE support.parks (
	block_id text;
);
ALTER TABLE london_index.block_cluster_labels 
	ADD COLUMN park boolean default False;
UPDATE london_index.block_cluster_labels SET park = True 
	WHERE block_id IN (
		SELECT * FROM support.parks
	);