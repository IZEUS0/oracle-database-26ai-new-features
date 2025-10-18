DROP TABLE if exists customer CASCADE CONSTRAINTS;

CREATE TABLE IF NOT EXISTS customer (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
);

-- Drop a table with IF EXISTS clause
DROP TABLE IF EXISTS customer;

-- We don't have a view but wont get an error using the if exists statement
DROP VIEW IF EXISTS customer_view;

CREATE TABLE IF NOT EXISTS customer (
customer_id NUMBER PRIMARY KEY,
first_name VARCHAR2(50),
last_name VARCHAR2(50)
);

-- Alter a table to add a column with IF EXISTS clause
ALTER TABLE IF EXISTS customer ADD (email VARCHAR2(100));

-- Attempt to alter a non existing table 
ALTER TABLE IF EXISTS t1 ADD (first_name VARCHAR2(50));

DROP TABLE customer CASCADE CONSTRAINTS;