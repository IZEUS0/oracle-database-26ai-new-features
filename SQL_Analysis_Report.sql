/* ===============================================================
   Author:      OLLEAR MENA  
   Company:     ELITEDATA
   Script:      SQL_Analysis_Report.sql  
   Lab Title:   SQL Analysis and Query Optimization in Oracle Database 26ai  
   Description: Demonstrates how to generate and interpret SQL execution 
                plans using EXPLAIN PLAN and DBMS_XPLAN to identify 
                inefficient operations (Cartesian joins, full scans, unions).  
                Includes optimization examples with indexed joins and 
                filtering strategies.  
   References:  https://docs.oracle.com/en/database/oracle/oracle-database/23/tgsql/
   Version:     1.0  
   Date:        SYSDATE  
   =============================================================== */




DROP TABLE IF EXISTS sales cascade constraints;
DROP TABLE IF EXISTS products cascade constraints;

CREATE TABLE sales (
    sale_id INT,
    quantity_sold INT,
    prod_id INT
);

CREATE TABLE products (
    prod_id INT,
    prod_name VARCHAR(100),
    prod_subcategory VARCHAR(50)
);

INSERT INTO sales (sale_id, quantity_sold, prod_id)
VALUES
    (1, 10, 101),
    (2, 20, 102),
    (3, 15, 103),
    (4, 12, 104),
    (5, 8, 105);

INSERT INTO products (prod_id, prod_name, prod_subcategory)
VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Smartphone', 'Electronics'),
(103, 'Headphones', 'Electronics'),
(104, 'Lion trouser Set', 'Clothing'),
(105, 'Shirt - Boys', 'Shirts'),
(106, 'Shirt - Girls', 'Shirts');

EXPLAIN PLAN FOR
SELECT sum(quantity_sold)
FROM   sales s,
    products p
WHERE  p.prod_name = 'Lion trouser Set';

SELECT * FROM table(DBMS_XPLAN.DISPLAY());

SELECT SUM(quantity_sold)
FROM   sales s
JOIN   products p ON s.prod_id = p.prod_id
WHERE  p.prod_name = 'Lion trouser Set';

EXPLAIN PLAN FOR
SELECT sum(quantity_sold)
FROM   sales s
JOIN   products p ON s.prod_id = p.prod_id
WHERE  p.prod_name = 'Lion trouser Set';

SELECT * FROM table(DBMS_XPLAN.DISPLAY());

EXPLAIN PLAN FOR
SELECT prod_name
FROM   products
WHERE  prod_subcategory = 'Shirts - Girls'
UNION
SELECT prod_name
FROM   products
WHERE  prod_subcategory = 'Shirts - Boys';

SELECT * FROM table(DBMS_XPLAN.DISPLAY());

EXPLAIN PLAN FOR
SELECT prod_name
FROM   products
WHERE  prod_subcategory = 'Shirts - Boys'
UNION ALL
SELECT prod_name
FROM   products
WHERE  prod_subcategory = 'Shirts - Girls';

SELECT * FROM table(DBMS_XPLAN.DISPLAY());

DROP TABLE sales cascade constraints;

DROP TABLE products cascade constraints;
