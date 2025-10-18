/* ===============================================================
   Reviewer: Ollear Mena
   Company: ELITEDATA S.L. 
   Script:      Table_Value_Constructors_SQL.sql  
   Lab Title:   Table Value Constructors (TVC) in Oracle Database 26ai  
   Description: Demonstrates the use of Table Value Constructors
                to define inline row sets in SQL statements.  
                Includes examples for INSERT, UPDATE, DELETE, and MERGE 
                operations using VALUES clauses.  
   References:  https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/
   Version:     1.0  
   Date:        SYSDATE  
   =============================================================== */


DROP TABLE if exists EMPLOYEES cascade constraints;
DROP TABLE if exists PRODUCTS cascade constraints;

-- Create a table to store employee data
CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50)
);

-- Create a table to store product data
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    category VARCHAR(50)
);

DROP TABLE if exists EMPLOYEES cascade constraints;
DROP TABLE if exists PRODUCTS cascade constraints;

-- Create a table to store employee data
CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50)
);

-- Create a table to store product data
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    category VARCHAR(50)
);

-- Insert sample data into the employees table
INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (1, 'John', 'Doe', 'IT');

INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (2, 'Jane', 'Smith', 'HR');

INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (3, 'Bob', 'Johnson', 'Finance');

-- Insert sample data into the products table
INSERT INTO products (product_id, product_name, price, category)
VALUES
    (101, 'Laptop', 1200.00, 'Electronics');

INSERT INTO products (product_id, product_name, price, category)
VALUES
    (102, 'Smartphone', 800.00, 'Electronics');

INSERT INTO products (product_id, product_name, price, category)
VALUES
    (103, 'Headphones', 150.00, 'Electronics');

INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (4, 'Emily', 'Johnson', 'Marketing'),
    (5, 'Michael', 'Williams', 'Sales'),
    (6, 'Kyle', 'Brown', 'HR');

UPDATE employees
SET department = 'IT'
WHERE first_name IN (
    SELECT first_name
    FROM (
        VALUES ('John'), ('Jane')
    ) AS first_names(first_name)
);

DELETE FROM employees
WHERE department IN (
    SELECT department
    FROM (
        VALUES ('HR')
    ) AS departments(department)
);

MERGE INTO products target
USING (
    VALUES
        (104, 'Tablet', 500.00, 'Electronics'),
        (105, 'Smartwatch', 250.00, 'Electronics')
) source (product_id, product_name, price, category)
ON (target.product_id = source.product_id)
WHEN MATCHED THEN
    UPDATE SET
        target.product_name = source.product_name,
        target.price = source.price,
        target.category = source.category
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name, price, category)
    VALUES (source.product_id, source.product_name, source.price, source.category);

DROP TABLE EMPLOYEES cascade constraints;

DROP TABLE PRODUCTS cascade constraints;

