--Understanding the need for tablespace shrinkage
SELECT tablespace_name,
    ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS "Size_GB"
FROM dba_data_files
where TABLESPACE_NAME = 'DATA'
GROUP BY tablespace_name;

drop table if exists my_table purge;


CREATE TABLE my_table (
    id NUMBER,
    name VARCHAR2(100),
    description VARCHAR2(1000)
);

--We'll now add 2 million rows to the table
DECLARE
    v_id NUMBER;
    v_name VARCHAR2(100);
    v_description VARCHAR2(1000);
BEGIN
    FOR i IN 1..2000000 LOOP -- Inserting 2 million rows
        v_id := i;
        v_name := 'Name_' || i;
        v_description := 'Description for row ' || i;

        INSERT INTO my_table (id, name, description) VALUES (v_id, v_name, v_description);

        IF MOD(i, 1000) = 0 THEN
            COMMIT; -- Commit every 1000 rows to avoid running out of undo space
        END IF;
    END LOOP;
    COMMIT; -- Final commit
END;

SELECT tablespace_name,
    ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS "Size_GB"
FROM dba_data_files
where TABLESPACE_NAME = 'DATA'
GROUP BY tablespace_name;

drop table my_table cascade constraints;

SELECT tablespace_name,
    ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS "Size_GB"
FROM dba_data_files
where TABLESPACE_NAME = 'DATA'
GROUP BY tablespace_name;

execute dbms_space.SHRINK_TABLESPACE('DATA', SHRINK_MODE=>DBMS_SPACE.TS_MODE_ANALYZE);

execute dbms_space.SHRINK_TABLESPACE('DATA');

execute dbms_space.SHRINK_TABLESPACE('DATA', SHRINK_MODE=>DBMS_SPACE.TS_MODE_ANALYZE);