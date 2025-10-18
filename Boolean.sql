/* ===============================================================
   Author:      OLLEAR MENA 
   Company:     ELITEDATA 
   Script:      Boolean.sql  
   Lab Title:   Working with the BOOLEAN Data Type in Oracle Database 26ai  
   Description: Demonstrates the use of the native BOOLEAN data type 
                introduced in Oracle 26ai. Includes table creation, 
                data insertion, conditional queries, updates, and PL/SQL 
                operations using TRUE, FALSE, and NULL values.  
   References:  https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/
   Version:     1.0  
   Date:        SYSDATE  
   =============================================================== */


DROP TABLE IF EXISTS MOVIES CASCADE CONSTRAINT;

-- Create MOVIES table with a boolean column
CREATE TABLE MOVIES (
    MOVIE_ID   NUMBER PRIMARY KEY,
    TITLE      VARCHAR2(100),
    RECOMMENDED BOOLEAN
);

-- Insert sample data using boolean values and accepted boolean literals
INSERT INTO MOVIES VALUES (1, 'The Matrix', TRUE),
                        (2, 'Jaws', FALSE),
                        (3, 'Casablanca', 'yes'),
                        (4, 'Plan 9 From Outer Space', 'no'),
                        (5, 'Inception', 'on'),
                        (6, 'Sharknado', 'off'),
                        (7, 'Interstellar', 1),
                        (8, 'The Room', 0),
                        (9, 'Sicario', NULL );

SELECT movie_id, title, recommended
FROM movies;

SELECT movie_id, title
FROM movies
WHERE recommended = TRUE;

-- Select movies where recommended AND TRUE is still TRUE
SELECT movie_id, title
FROM movies
WHERE recommended AND TRUE;

SELECT movie_id, title
FROM movies
WHERE NOT recommended;

SELECT movie_id, title
FROM movies
WHERE recommended OR title LIKE 'I%';

SELECT title, recommended from movies where movie_id = 2;

UPDATE movies
SET recommended = true
WHERE movie_id = 2;

SELECT title, recommended from movies where movie_id = 2;

DECLARE
    l_movie_id NUMBER := 10;
    l_movie_name VARCHAR2(100) := 'Surfs Up'; 
    l_recommended BOOLEAN := TRUE;
BEGIN
    INSERT INTO movies (movie_id, title, recommended)
    VALUES (l_movie_id, l_movie_name, l_recommended);

    COMMIT;
END;
/

SELECT movie_id, title
FROM movies
WHERE recommended = TRUE;


DROP TABLE IF EXISTS MOVIES CASCADE CONSTRAINT;
