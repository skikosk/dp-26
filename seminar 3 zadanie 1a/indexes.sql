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
