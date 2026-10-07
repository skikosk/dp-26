-- 1. Vytvorenie databazy (spustit napr. v databaze postgres)
CREATE DATABASE retail_sales;

-- Dalsie prikazy spustit uz v databaze retail_sales

-- 2. Vytvorenie tabulky orders
CREATE TABLE orders (
    order_id    VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id  VARCHAR(20) NOT NULL,
    order_date  DATE NOT NULL,
    region      VARCHAR(20) NOT NULL,
    category    VARCHAR(50) NOT NULL,
    ship_mode   VARCHAR(30) NOT NULL,
    sales       DECIMAL(10, 2) NOT NULL,
    profit      DECIMAL(10, 2) NOT NULL
);

-- 3. Format datumu mesiac/den/rok (prejavi sa v novych pripojeniach)
ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

-- 6. Overenie importovanych dat
SELECT *
FROM orders;
