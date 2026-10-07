-- Databaza: superstore

-- Uloha 8 - Celkovy predaj zakaznika pomocou procedury
CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR(20))
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_total NUMERIC(10, 2);
BEGIN
    SELECT SUM(sales)
    INTO v_total
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Customer %: total sales %', p_customer_id, v_total;
END;
$procedure$;

CALL get_customer_sales('C001');
