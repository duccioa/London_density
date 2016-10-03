----  Create logical for inner/outer Central Activity Zone (CAZ) ----
---- Blocks ----
ALTER TABLE london_index.block_cluster_labels 
	ADD COLUMN caz boolean;
UPDATE london_index.block_cluster_labels AS t1 SET caz= 
	(SELECT st_within(st_centroid(t2.geom_block), t3.geom) 
	FROM london_index.block_cluster_labels AS t2, london.caz AS t3 WHERE t1.block_id=t2.block_id);
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
---- Plots ----
ALTER TABLE london_index.plot_cluster_labels 
	ADD COLUMN caz boolean;
UPDATE london_index.plot_cluster_labels AS t1 SET caz= 
	(SELECT st_within(st_centroid(t2.geom_plot), t3.geom) 
	FROM london_index.plot_cluster_labels AS t2, london.caz AS t3 WHERE t1.plot_id=t2.plot_id);
-- Add PARK column
CREATE TABLE support.plot_parks (
	plot_id text
);
ALTER TABLE support.plot_parks 
	ADD PRIMARY KEY (plot_id);
INSERT INTO support.plot_parks 
	VALUES (465159),
		(466702),
		(466703),
		(466701),
		(466707),
		(1308357),
		(1310825),
		(461691),
		(461666),
		(434232),
		(403672),
		(434233),
		(434231),
		(461665),
		(461667),
		(463681),
		(458882),
		(458894),
		(458895),
		(458902),
		(456706),
		(456723),
		(2009591);
ALTER TABLE london_index.plot_cluster_labels 
	ADD COLUMN park boolean default False;
UPDATE london_index.plot_cluster_labels SET park = True 
	WHERE plot_id IN (
		SELECT * FROM support.plot_parks
	);