-- Databaza: superstore

-- Uloha 1 - Pohlad pre zakaznikov s vysokou hodnotou predaja
CREATE OR REPLACE VIEW high_value_customers AS
SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT *
FROM high_value_customers;

-- Uloha 2 - Mesacny predaj podla regionu
CREATE OR REPLACE VIEW regional_monthly_sales AS
SELECT
    c.region,
    DATE_TRUNC('month', o.order_date)::DATE AS month,
    SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region, DATE_TRUNC('month', o.order_date);

SELECT *
FROM regional_monthly_sales
WHERE region = 'West'
ORDER BY month;

-- Uloha 3 - Pohlad pre analytikov (bez stlpca profit)
CREATE OR REPLACE VIEW analyst_orders AS
SELECT
    order_id,
    customer_id,
    product_id,
    sales,
    quantity,
    discount
FROM orders;

SELECT *
FROM analyst_orders;

-- Aby analytik nevidel profit ani v zdrojovej tabulke, musi mat pristup iba cez view
-- (predpoklada existujucu rolu analyst):
-- REVOKE SELECT ON orders FROM analyst;
-- GRANT SELECT ON analyst_orders TO analyst;
