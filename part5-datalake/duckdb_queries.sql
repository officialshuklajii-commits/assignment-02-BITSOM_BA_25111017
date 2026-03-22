-- ============================================================
-- Part 5 — Data Lake & DuckDB Queries (duckdb_queries.sql)
-- ============================================================
-- All queries read DIRECTLY from raw files — no pre-loading.
-- Run from the repository root directory with:
--   duckdb < part5-datalake/duckdb_queries.sql
--
-- File schema reference:
--   customers.csv    → customer_id, name, city, signup_date, email
--   orders.json      → order_id, customer_id, order_date, status,
--                       total_amount, num_items
--   products.parquet → line_item_id, order_id, product_id,
--                       product_name, category, quantity,
--                       unit_price, total_price
--
-- Key design note: products.parquet is an ORDER LINE-ITEMS table.
-- It links to orders.json via the shared `order_id` column.
-- This enables a three-way join:
--   customers.csv ←→ orders.json (customer_id) ←→ products.parquet (order_id)
-- ============================================================

-- ============================================================
-- Q1: List all customers along with the total number of orders
--     they have placed
-- ============================================================
SELECT
    c.customer_id,
    c.name                          AS customer_name,
    c.city,
    c.email,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spend
FROM read_csv_auto('datasets/customers.csv')      AS c
LEFT JOIN read_json_auto('datasets/orders.json')  AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city, c.email
ORDER BY total_orders DESC, total_spend DESC;

-- ============================================================
-- Q2: Find the top 3 customers by total order value
-- ============================================================
SELECT
    c.customer_id,
    c.name                          AS customer_name,
    c.city,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    SUM(o.total_amount)             AS total_order_value
FROM read_csv_auto('datasets/customers.csv')      AS c
JOIN read_json_auto('datasets/orders.json')       AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_order_value DESC
LIMIT 3;

-- ============================================================
-- Q3: List all products purchased by customers from Bangalore
-- Join path:
--   customers.csv (city='Bangalore')
--     → orders.json     (on customer_id)
--     → products.parquet (on order_id)
-- ============================================================
SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    c.name          AS purchased_by,
    c.city
FROM read_csv_auto('datasets/customers.csv')       AS c
JOIN read_json_auto('datasets/orders.json')        AS o
    ON c.customer_id = o.customer_id
JOIN read_parquet('datasets/products.parquet')     AS p
    ON o.order_id = p.order_id
WHERE c.city = 'Bangalore'
ORDER BY p.category, p.product_name;

-- ============================================================
-- Q4: Join all three files to show: customer name, order date,
--     product name, and quantity
-- Full three-way join across all file formats
-- ============================================================
SELECT
    c.name          AS customer_name,
    c.city          AS customer_city,
    o.order_date,
    o.status        AS order_status,
    p.product_name,
    p.category,
    p.quantity,
    p.unit_price,
    p.total_price
FROM read_json_auto('datasets/orders.json')        AS o
JOIN read_csv_auto('datasets/customers.csv')       AS c
    ON o.customer_id = c.customer_id
JOIN read_parquet('datasets/products.parquet')     AS p
    ON o.order_id = p.order_id
ORDER BY o.order_date DESC, c.name, p.product_name;
