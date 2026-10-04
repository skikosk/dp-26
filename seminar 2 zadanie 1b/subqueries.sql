-- Uloha 1 - Transakcie nad priemernou hodnotou
SELECT
    product_name,
    total_amount
FROM flourmills_sales
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM flourmills_sales
);

-- Uloha 2 - Transakcie najpredavanejsej kategorie
SELECT *
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id;
