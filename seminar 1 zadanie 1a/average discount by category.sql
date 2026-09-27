SELECT
    p.category,
    ROUND(AVG(o.discount), 2) AS avg_discount
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount DESC;