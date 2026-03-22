-- ============================================================
-- Part 3 — Data Warehouse Analytical Queries (dw_queries.sql)
-- Run AFTER star_schema.sql has been executed
-- ============================================================

-- Q1: Total sales revenue by product category for each month
SELECT
    d.year,
    d.month_num                           AS month,
    d.month_name,
    p.category,
    COUNT(f.transaction_id)               AS total_transactions,
    SUM(f.units_sold)                     AS total_units,
    ROUND(SUM(f.total_revenue), 2)        AS total_revenue
FROM fact_sales  f
JOIN dim_date    d ON f.date_key    = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY d.year, d.month_num, d.month_name, p.category
ORDER BY d.year, d.month_num, p.category;

-- Q2: Top 2 performing stores by total revenue
SELECT
    s.store_name,
    s.store_city,
    s.store_zone,
    COUNT(f.transaction_id)               AS total_transactions,
    SUM(f.units_sold)                     AS total_units_sold,
    ROUND(SUM(f.total_revenue), 2)        AS total_revenue,
    ROUND(AVG(f.total_revenue), 2)        AS avg_transaction_value
FROM fact_sales f
JOIN dim_store  s ON f.store_key = s.store_key
GROUP BY s.store_key, s.store_name, s.store_city, s.store_zone
ORDER BY total_revenue DESC
LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
-- Uses a CTE to first aggregate monthly totals, then applies
-- the LAG() window function on the aggregated result set.
-- This is necessary because LAG() cannot be used directly
-- inside a GROUP BY expression.
WITH monthly_totals AS (
    SELECT
        d.year,
        d.month_num,
        d.month_name,
        COUNT(f.transaction_id)           AS total_transactions,
        ROUND(SUM(f.total_revenue), 2)    AS monthly_revenue
    FROM fact_sales f
    JOIN dim_date   d ON f.date_key = d.date_key
    GROUP BY d.year, d.month_num, d.month_name
)
SELECT
    year,
    month_num,
    month_name,
    total_transactions,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        ORDER BY year, month_num
    )                                     AS prev_month_revenue,
    ROUND(
        100.0 * (
            monthly_revenue
            - LAG(monthly_revenue) OVER (ORDER BY year, month_num)
        )
        / NULLIF(
            LAG(monthly_revenue) OVER (ORDER BY year, month_num), 0
        ),
        2
    )                                     AS mom_growth_pct
FROM monthly_totals
ORDER BY year, month_num;
