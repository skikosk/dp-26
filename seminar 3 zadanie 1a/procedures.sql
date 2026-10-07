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

-- Uloha 9 - Procedura na aplikovanie regionalnej zlavy
CREATE OR REPLACE PROCEDURE apply_regional_discount(region_name VARCHAR(50), discount_rate NUMERIC(5, 2))
LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE orders o
    SET sales = o.sales * (1 - discount_rate)
    FROM customers c
    WHERE o.customer_id = c.customer_id
      AND c.region = region_name;

    RAISE NOTICE 'Discount % applied to region %', discount_rate, region_name;
END;
$procedure$;

-- Pozor: kazde volanie trvalo meni data v orders (opakovane volanie zlavu znova uplatni)
-- CALL apply_regional_discount('West', 0.10);
