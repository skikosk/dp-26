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

-- Uloha 3 - Porovnanie transakcie s priemernou hodnotou
SELECT
    product_name,
    total_amount,
    (
        SELECT AVG(total_amount)
        FROM flourmills_sales
    ) AS avg_amount
FROM flourmills_sales;

-- Uloha 4 - Podiel transakcie na celkovom predaji
SELECT
    product_name,
    total_amount,
    total_amount / (
        SELECT SUM(total_amount)
        FROM flourmills_sales
    ) AS amount_share
FROM flourmills_sales;

-- Uloha 5 - Mesacny prehlad predaja
SELECT *
FROM (
    SELECT
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_amount) AS monthly_sales
    FROM flourmills_sales
    GROUP BY EXTRACT(MONTH FROM sale_date)
) AS monthly_view
ORDER BY monthly_sales DESC;
