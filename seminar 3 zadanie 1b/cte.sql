-- Databaza: datacraftinglab_db

-- Uloha 1 - Dni s mimoriadne vysokym predajom
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT
    sale_date,
    total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

-- Uloha 2 - Predaj podla produktovych kategorii
WITH category_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT
    product_category,
    total_sales
FROM category_sales
ORDER BY total_sales DESC;

-- Uloha 3 - Top produkty v jednotlivych kategoriach
WITH product_sales AS (
    SELECT
        product_category,
        product_name,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT
        product_category,
        product_name,
        total_product_sales,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_product_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT
    product_category,
    product_name,
    total_product_sales,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category, category_rank;

-- Uloha 4 - Podiel zakaznickych typov na celkovom predaji
WITH customer_type_revenue AS (
    SELECT
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
revenue_share AS (
    SELECT
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND(revenue * 100 / SUM(revenue) OVER (), 2) AS revenue_percentage
    FROM customer_type_revenue
)
SELECT
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM revenue_share
ORDER BY revenue DESC;

-- Uloha 5 - Posledny nakup kazdeho zakaznika
WITH customer_purchases AS (
    SELECT
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS rn
    FROM flourmills_sales
)
SELECT
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM customer_purchases
WHERE rn = 1
ORDER BY customer_id;

-- Uloha 6 - Suvisly kalendar predajov
WITH RECURSIVE date_range AS (
    SELECT
        MIN(sale_date) AS start_date,
        MAX(sale_date) AS end_date
    FROM flourmills_sales
),
calendar AS (
    SELECT start_date AS calendar_date, end_date
    FROM date_range

    UNION ALL

    SELECT (calendar_date + 1)::DATE, end_date
    FROM calendar
    WHERE calendar_date < end_date
)
SELECT calendar_date
FROM calendar
ORDER BY calendar_date;
