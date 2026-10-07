-- Databaza: superstore

-- Uloha 4 - Index pre vyhladavanie objednavok zakaznika
CREATE INDEX idx_orders_customer_id
ON orders (customer_id);

SELECT *
FROM orders
WHERE customer_id = 'C001';
