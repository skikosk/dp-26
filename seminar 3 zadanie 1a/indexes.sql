-- Databaza: superstore

-- Uloha 4 - Index pre vyhladavanie objednavok zakaznika
CREATE INDEX idx_orders_customer_id
ON orders (customer_id);

SELECT *
FROM orders
WHERE customer_id = 'C001';

-- Uloha 5 - Index nad datumom objednavky
CREATE INDEX idx_orders_order_date
ON orders (order_date);

SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    SUM(sales)
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Uloha 6 - Viacstlpcovy index a filtrovanie podla regionu a datumu
CREATE INDEX idx_orders_region_category
ON orders (customer_id, order_date);

SELECT
    c.customer_name,
    c.region,
    o.order_id,
    o.order_date,
    o.sales,
    o.profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'West'
  AND o.order_date >= '2024-01-01';

-- Uloha 7 - Analyza planu vykonania dotazu
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';
