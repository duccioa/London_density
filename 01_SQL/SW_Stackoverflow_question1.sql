---- CREATE SAMPLE TABLES
-- Main table
DROP TABLE IF EXISTS test_main CASCADE;
DROP TABLE IF EXISTS test_1 CASCADE;
DROP TABLE IF EXISTS test_2 CASCADE;
DROP TABLE IF EXISTS iteration CASCADE;
CREATE TABLE test_main (gid integer, descr text, PRIMARY KEY (gid));
INSERT INTO test_main VALUES (1,'a');
INSERT INTO test_main VALUES (2,'c');
INSERT INTO test_main VALUES (3,'b');
-- Two joining tables
CREATE TABLE test_1 (gid integer, var2 text, PRIMARY KEY (gid));
INSERT INTO test_1 VALUES (1,'xx');
INSERT INTO test_1 VALUES (2,'zx');
INSERT INTO test_1 VALUES (3,'yx');
CREATE TABLE test_2 (gid integer, var2 text, PRIMARY KEY (gid));
INSERT INTO test_2 VALUES (1,'zz');
INSERT INTO test_2 VALUES (2,'yy');
INSERT INTO test_2 VALUES (3,'yz');
-- List of joining tables 
CREATE TABLE iteration (iter text, PRIMARY KEY (iter));
INSERT INTO iteration VALUES ('test_1');
INSERT INTO iteration VALUES ('test_2');
---- Iterate join function
DROP FUNCTION IF EXISTS test_pg();
CREATE FUNCTION test_pg() 
	RETURNS TABLE (gid integer, descr text, var2 text) 
	AS $$
		DECLARE 
			i text;
			
		BEGIN
			FOR i IN SELECT iter FROM iteration 
			LOOP
			RETURN QUERY
			EXECUTE format('SELECT t1.gid, descr, var2 FROM test_main t1 JOIN %s t2 ON t1.gid = t2.gid', i);
			END LOOP;
			RETURN;
		END;
	$$ 
	LANGUAGE plpgsql 
	STABLE;
	
SELECT * FROM test_pg();
