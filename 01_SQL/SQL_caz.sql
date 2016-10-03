--ALTER TABLE london_index.block_cluster_labels 
--	ADD COLUMN caz boolean;
UPDATE london_index.block_cluster_labels AS t1 SET caz= 
	(SELECT st_within(st_centroid(t2.geom_block), t3.geom) 
	FROM london_index.block_cluster_labels AS t2, london.caz AS t3 WHERE t1.block_id=t2.block_id);