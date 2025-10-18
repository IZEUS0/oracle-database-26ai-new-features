--Enabling SQL Firewall
-- Create USER SQL
CREATE USER TEST IDENTIFIED BY Oracledb_4U#;

-- Grant roles
GRANT CONNECT TO TEST;
GRANT RESOURCE TO TEST;
GRANT SQL_FIREWALL_ADMIN TO TEST WITH ADMIN OPTION;

-- Enable REST
BEGIN
    ORDS_ADMIN.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => 'TEST',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'test',
        p_auto_rest_auth=> TRUE
    );

    -- Enable data sharing
    C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
            SCHEMA_NAME => 'TEST',
            ENABLED => TRUE
    );
    commit;
END;
/

-- Set quota
ALTER USER TEST QUOTA 100M ON DATA;

-- USER SQL
CREATE USER DB23AI IDENTIFIED BY Oracledb_4U#;

-- ADD ROLES
GRANT CONNECT TO DB23AI;
GRANT DB_DEVELOPER_ROLE TO DB23AI;
GRANT RESOURCE TO DB23AI;

-- REST ENABLE
BEGIN
    ORDS_ADMIN.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => 'DB23AI',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'db23ai',
        p_auto_rest_auth=> TRUE
    );
    -- ENABLE DATA SHARING
    C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
            SCHEMA_NAME => 'DB23AI',
            ENABLED => TRUE
    );
    commit;
END;
/

-- QUOTA
ALTER USER DB23AI QUOTA UNLIMITED ON DATA;


/*
--Sign in to the TEST user using credentials
	SHOW USER

	EXEC DBMS_SQL_FIREWALL.ENABLE;

	BEGIN
		DBMS_SQL_FIREWALL.CREATE_CAPTURE(
			username => 'DB23AI',
			top_level_only => TRUE,
			start_capture => TRUE
		);
	END;
	/

*/

----Now sign out of the TEST user and back in as the DB23AI user.

DROP TABLE IF EXISTS EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS DEPARTMENTS CASCADE CONSTRAINTS;

-- Create employees table
CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT
);

-- Create departments table
CREATE TABLE departments (
    department_id INT,
    department_name VARCHAR(50)
);

-- Insert data into departments table
INSERT INTO departments (department_id, department_name)
VALUES
    (1, 'HR'),
    (2, 'IT'),
    (3, 'Finance');
	



--Log back in as the TEST user
EXEC DBMS_SQL_FIREWALL.STOP_CAPTURE('DB23AI');

SELECT sql_text
FROM DBA_SQL_FIREWALL_CAPTURE_LOGS
WHERE username = 'DB23AI';

SELECT sql_text
FROM DBA_SQL_FIREWALL_ALLOWED_SQL
WHERE username = 'DB23AI';

EXEC DBMS_SQL_FIREWALL.GENERATE_ALLOW_LIST('DB23AI');
EXEC DBMS_SQL_FIREWALL.ENABLE_ALLOW_LIST(username=>'DB23AI', enforce=>DBMS_SQL_FIREWALL.ENFORCE_SQL, block=>TRUE);



--Now sign out of the TEST user and back in as the DB23AI user.
SELECT * FROM DEPARTMENTS; --it will be blocked


--Log back in as the TEST user
EXEC DBMS_SQL_FIREWALL.DISABLE_ALLOW_LIST(username=>'DB23AI');

SELECT SQL_TEXT, FIREWALL_ACTION, IP_ADDRESS, CAUSE, OCCURRED_AT
FROM DBA_SQL_FIREWALL_VIOLATIONS WHERE USERNAME = 'DB23AI';



--Clean UP

--Log in as the ADMIN user
BEGIN
FOR session IN (SELECT SID, SERIAL# FROM V$SESSION WHERE USERNAME = 'TEST') LOOP
    EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || session.SID || ',' || session.SERIAL# || ''' IMMEDIATE';
END LOOP;
END;
/

BEGIN
FOR session IN (SELECT SID, SERIAL# FROM V$SESSION WHERE USERNAME = 'DB23AI') LOOP
    EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || session.SID || ',' || session.SERIAL# || ''' IMMEDIATE';
END LOOP;
END;

DROP USER TEST CASCADE;
DROP USER DB23AI CASCADE;





