-- Runs the intersect query on the test sample
-- Needs the table 'iterations' created by the script
DROP TABLE IF EXISTS london_streetwidth.results;
CREATE TABLE london_streetwidth.results AS 
	SELECT * FROM london_streetwidth.SW_Intersect_pg();
ALTER TABLE london_streetwidth.results ADD COLUMN row_id SERIAL PRIMARY KEY;