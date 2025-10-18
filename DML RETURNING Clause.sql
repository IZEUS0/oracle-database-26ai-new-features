DROP TABLE if exists PRODUCTS CASCADE CONSTRAINT;

-- Create PRODUCTS table
CREATE TABLE PRODUCTS (
    PRODUCT_ID INT PRIMARY KEY,
    PRODUCT_NAME VARCHAR(100),
    PRICE DECIMAL(10,2),
    LAST_UPDATED DATE
);

-- Insert sample data
INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRICE, LAST_UPDATED) VALUES
(1, 'Gaming Laptop', 1299.99, SYSDATE),
(2, 'Wireless Mouse', 49.99, SYSDATE),
(3, 'Mechanical Keyboard', 129.99, SYSDATE),
(4, 'Gaming Monitor', 399.99, SYSDATE),
(5, 'Gaming Headset', 89.99, SYSDATE);

SELECT PRODUCT_ID, PRODUCT_NAME, PRICE
FROM PRODUCTS
ORDER BY PRODUCT_ID;

DECLARE
    TYPE t_product_name IS TABLE OF VARCHAR2(100);
    TYPE t_price IS TABLE OF NUMBER;
    l_product_names t_product_name;
    l_old_prices t_price;
    l_new_prices t_price;
    l_price_differences t_price;
BEGIN
    UPDATE PRODUCTS
    SET PRICE = PRICE * 1.1,
        LAST_UPDATED = SYSDATE
    RETURNING 
        PRODUCT_NAME,
        OLD PRICE,
        NEW PRICE,
        ROUND((NEW PRICE - OLD PRICE), 2)
    BULK COLLECT INTO 
        l_product_names,
        l_old_prices,
        l_new_prices,
        l_price_differences;

    -- Display the results
    FOR i IN 1..l_product_names.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Product: ' || l_product_names(i) ||
            ', Old Price: $' || l_old_prices(i) ||
            ', New Price: $' || l_new_prices(i) ||
            ', Difference: $' || l_price_differences(i)
        );
    END LOOP;
END;
/

DECLARE
    TYPE t_product_name IS TABLE OF VARCHAR2(100);
    TYPE t_price IS TABLE OF NUMBER;
    TYPE t_date IS TABLE OF DATE;
    l_product_names t_product_name;
    l_prices t_price;
    l_last_updated t_date;
BEGIN
    DELETE FROM PRODUCTS 
    WHERE PRICE < 100
    RETURNING 
        PRODUCT_NAME,
        PRICE,
        LAST_UPDATED
    BULK COLLECT INTO 
        l_product_names,
        l_prices,
        l_last_updated;

    -- Display info about the deleted products
    FOR i IN 1..l_product_names.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Deleted Product: ' || l_product_names(i) ||
            ', Price: $' || l_prices(i) ||
            ', Last Updated: ' || TO_CHAR(l_last_updated(i), 'YYYY-MM-DD')
        );
    END LOOP;

    -- Show how many products were deleted
    DBMS_OUTPUT.PUT_LINE('Total products deleted: ' || l_product_names.COUNT);
END;
/

DECLARE
    l_product_id NUMBER;
    l_product_name VARCHAR2(100);
    l_price NUMBER;
    l_last_updated DATE;
BEGIN
    INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, PRICE, LAST_UPDATED)
    VALUES (6, 'Gaming Chair', 299.99, SYSDATE)
    RETURNING 
        PRODUCT_ID,
        PRODUCT_NAME,
        PRICE,
        LAST_UPDATED
    INTO
        l_product_id,
        l_product_name,
        l_price,
        l_last_updated;

    DBMS_OUTPUT.PUT_LINE(
        'Inserted Product - ID: ' || l_product_id ||
        ', Name: ' || l_product_name ||
        ', Price: $' || l_price ||
        ', Updated: ' || TO_CHAR(l_last_updated, 'YYYY-MM-DD')
    );
END;
/

DROP TABLE if exists PRODUCTS CASCADE CONSTRAINT;