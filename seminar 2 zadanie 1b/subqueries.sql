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

-- Uloha 6 - Kategorie s vysokym celkovym predajom
SELECT *
FROM (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
) AS category_sales
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

-- Uloha 7 - Predaj nad priemerom vlastnej kategorie
SELECT
    t1.product_name,
    t1.product_category,
    t1.total_amount
FROM flourmills_sales t1
WHERE t1.total_amount > (
    SELECT AVG(t2.total_amount)
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
);

-- Uloha 8 - Minimalna hodnota predaja v regione
SELECT
    t1.product_name,
    t1.region,
    t1.total_amount,
    (
        SELECT MIN(t2.total_amount)
        FROM flourmills_sales t2
        WHERE t2.region = t1.region
    ) AS region_min_amount
FROM flourmills_sales t1;
