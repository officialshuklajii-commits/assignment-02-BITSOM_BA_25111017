-- ============================================================
-- Part 1 — SQL Queries (queries.sql)
-- Run AFTER schema_design.sql has been executed
-- Database: retail_orders (or whichever DB you created)
-- ============================================================

-- Q1: List all customers from Mumbai along with their total order value
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_city,
    COUNT(o.order_id)                    AS total_orders,
    SUM(o.quantity * p.unit_price)       AS total_order_value
FROM customers c
JOIN orders  o ON c.customer_id  = o.customer_id
JOIN products p ON o.product_id  = p.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name, c.customer_city
ORDER BY total_order_value DESC;

-- Q2: Find the top 3 products by total quantity sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    SUM(o.quantity)                      AS total_quantity_sold,
    SUM(o.quantity * p.unit_price)       AS total_revenue
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.unit_price
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3: List all sales representatives and the number of unique customers they have handled
SELECT
    sr.sales_rep_id,
    sr.sales_rep_name,
    sr.sales_rep_email,
    off.city                             AS office_city,
    COUNT(DISTINCT o.customer_id)        AS unique_customers_handled,
    COUNT(o.order_id)                    AS total_orders_managed
FROM sales_reps sr
JOIN offices off ON sr.office_id        = off.office_id
LEFT JOIN orders o ON sr.sales_rep_id  = o.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name, sr.sales_rep_email, off.city
ORDER BY unique_customers_handled DESC;

-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.customer_city,
    p.product_name,
    p.category,
    o.quantity,
    p.unit_price,
    (o.quantity * p.unit_price)          AS total_order_value,
    sr.sales_rep_name
FROM orders o
JOIN customers  c  ON o.customer_id  = c.customer_id
JOIN products   p  ON o.product_id   = p.product_id
JOIN sales_reps sr ON o.sales_rep_id = sr.sales_rep_id
WHERE (o.quantity * p.unit_price) > 10000
ORDER BY total_order_value DESC;

-- Q5: Identify any products that have never been ordered
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    'Never ordered' AS status
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL
ORDER BY p.category, p.product_name;
