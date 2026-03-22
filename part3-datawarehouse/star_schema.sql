-- ============================================================
-- Part 3 — Data Warehouse: Star Schema Design
-- Source: retail_transactions.csv (300 rows, 9 columns)
-- ============================================================
-- ETL Issues resolved before loading:
--   1. Date formats: dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd → ISO
--   2. Category casing: 'electronics','Grocery' → 'Electronics','Groceries'
--   3. NULL store_city: resolved via store_name lookup mapping
-- ============================================================

-- Drop in reverse FK order (safe re-run)
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- ============================================================
-- DIMENSION: dim_date
-- Grain: one row per unique calendar date present in data
-- Attributes support time-intelligence queries (MoM, quarterly)
-- ============================================================
CREATE TABLE dim_date (
    date_key     INT          NOT NULL,  -- surrogate key: YYYYMMDD integer
    full_date    DATE         NOT NULL,
    day_of_month INT          NOT NULL,
    day_name     VARCHAR(10)  NOT NULL,
    week_number  INT          NOT NULL,
    month_num    INT          NOT NULL,
    month_name   VARCHAR(15)  NOT NULL,
    quarter      INT          NOT NULL,
    year         INT          NOT NULL,
    is_weekend   BOOLEAN      NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

-- ============================================================
-- DIMENSION: dim_store
-- Grain: one row per physical store location
-- NULL store_city rows from source resolved via ETL lookup
-- ============================================================
CREATE TABLE dim_store (
    store_key   INT          NOT NULL,  -- surrogate key
    store_name  VARCHAR(100) NOT NULL,
    store_city  VARCHAR(50)  NOT NULL,
    store_zone  VARCHAR(20)  NOT NULL,  -- North/South/West/East
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

-- ============================================================
-- DIMENSION: dim_product
-- Grain: one row per unique product
-- Category values standardised to Title Case during ETL
-- ============================================================
CREATE TABLE dim_product (
    product_key   INT           NOT NULL,  -- surrogate key
    product_name  VARCHAR(100)  NOT NULL,
    category      VARCHAR(50)   NOT NULL,  -- standardised: Electronics/Clothing/Groceries
    unit_price    DECIMAL(12,2) NOT NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

-- ============================================================
-- FACT TABLE: fact_sales
-- Grain: one row per retail transaction
-- Measures: units_sold (additive), unit_price (semi-additive),
--           total_revenue (additive — pre-computed for performance)
-- ============================================================
CREATE TABLE fact_sales (
    transaction_id VARCHAR(15)    NOT NULL,
    date_key       INT            NOT NULL,
    store_key      INT            NOT NULL,
    product_key    INT            NOT NULL,
    customer_id    VARCHAR(15)    NOT NULL,
    units_sold     INT            NOT NULL  CHECK (units_sold > 0),
    unit_price     DECIMAL(12,2)  NOT NULL,
    total_revenue  DECIMAL(14,2)  NOT NULL,  -- = units_sold * unit_price
    CONSTRAINT pk_fact_sales   PRIMARY KEY (transaction_id),
    CONSTRAINT fk_fs_date      FOREIGN KEY (date_key)    REFERENCES dim_date(date_key),
    CONSTRAINT fk_fs_store     FOREIGN KEY (store_key)   REFERENCES dim_store(store_key),
    CONSTRAINT fk_fs_product   FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- ============================================================
-- INSERT: dim_date (all unique dates present in transactions)
-- ============================================================
INSERT INTO dim_date (date_key, full_date, day_of_month, day_name, week_number, month_num, month_name, quarter, year, is_weekend) VALUES
(20230115, '2023-01-15', 15, 'Sunday',    2,  1, 'January',   1, 2023, TRUE),
(20230205, '2023-02-05',  5, 'Sunday',    5,  2, 'February',  1, 2023, TRUE),
(20230220, '2023-02-20', 20, 'Monday',    8,  2, 'February',  1, 2023, FALSE),
(20230331, '2023-03-31', 31, 'Friday',   13,  3, 'March',     1, 2023, FALSE),
(20230428, '2023-04-28', 28, 'Friday',   17,  4, 'April',     2, 2023, FALSE),
(20230521, '2023-05-21', 21, 'Sunday',   20,  5, 'May',       2, 2023, TRUE),
(20230604, '2023-06-04',  4, 'Sunday',   22,  6, 'June',      2, 2023, TRUE),
(20230722, '2023-07-22', 22, 'Saturday', 29,  7, 'July',      3, 2023, TRUE),
(20230809, '2023-08-09',  9, 'Wednesday',32,  8, 'August',    3, 2023, FALSE),
(20230815, '2023-08-15', 15, 'Tuesday',  33,  8, 'August',    3, 2023, FALSE),
(20230829, '2023-08-29', 29, 'Tuesday',  35,  8, 'August',    3, 2023, FALSE),
(20231020, '2023-10-20', 20, 'Friday',   42, 10, 'October',   4, 2023, FALSE),
(20231026, '2023-10-26', 26, 'Thursday', 43, 10, 'October',   4, 2023, FALSE),
(20231118, '2023-11-18', 18, 'Saturday', 46, 11, 'November',  4, 2023, TRUE),
(20231208, '2023-12-08',  8, 'Friday',   49, 12, 'December',  4, 2023, FALSE),
(20231212, '2023-12-12', 12, 'Tuesday',  50, 12, 'December',  4, 2023, FALSE);

-- ============================================================
-- INSERT: dim_store (5 stores — NULL city resolved via ETL)
-- ============================================================
INSERT INTO dim_store (store_key, store_name, store_city, store_zone) VALUES
(1, 'Chennai Anna',   'Chennai',   'South'),
(2, 'Delhi South',    'Delhi',     'North'),
(3, 'Bangalore MG',   'Bangalore', 'South'),
(4, 'Pune FC Road',   'Pune',      'West'),
(5, 'Mumbai Central', 'Mumbai',    'West');

-- ============================================================
-- INSERT: dim_product (all 16 products from retail_transactions)
-- Category ETL: 'electronics' → 'Electronics', 'Grocery' → 'Groceries'
-- ============================================================
INSERT INTO dim_product (product_key, product_name, category, unit_price) VALUES
(1,  'Atta 10kg',   'Groceries',   52464.00),
(2,  'Biscuits',    'Groceries',   27469.99),
(3,  'Headphones',  'Electronics', 39854.96),
(4,  'Jacket',      'Clothing',    30187.24),
(5,  'Jeans',       'Clothing',     2317.47),
(6,  'Laptop',      'Electronics', 42343.15),
(7,  'Milk 1L',     'Groceries',   43374.39),
(8,  'Oil 1L',      'Groceries',   26474.34),
(9,  'Phone',       'Electronics', 48703.39),
(10, 'Pulses 1kg',  'Groceries',   31604.47),
(11, 'Rice 5kg',    'Groceries',   52195.05),
(12, 'Saree',       'Clothing',    35451.81),
(13, 'Smartwatch',  'Electronics', 58851.01),
(14, 'Speaker',     'Electronics', 49262.78),
(15, 'T-Shirt',     'Clothing',    29770.19),
(16, 'Tablet',      'Electronics', 23226.12);

-- ============================================================
-- INSERT: fact_sales (15 cleaned rows from retail_transactions)
-- All dates normalised to ISO; categories standardised;
-- NULL store_city resolved; total_revenue pre-computed
-- ============================================================
INSERT INTO fact_sales (transaction_id, date_key, store_key, product_key, customer_id, units_sold, unit_price, total_revenue) VALUES
('TXN5000', 20230829, 1, 14, 'CUST045',  3,  49262.78,  147788.34),
('TXN5001', 20231212, 1, 16, 'CUST021', 11,  23226.12,  255487.32),
('TXN5002', 20230205, 1,  9, 'CUST019', 20,  48703.39,  974067.80),
('TXN5003', 20230220, 2, 16, 'CUST007', 14,  23226.12,  325165.68),
('TXN5004', 20230115, 1, 13, 'CUST004', 10,  58851.01,  588510.10),
('TXN5005', 20230809, 3,  1, 'CUST027', 12,  52464.00,  629568.00),
('TXN5006', 20230331, 4, 13, 'CUST025',  6,  58851.01,  353106.06),
('TXN5007', 20231026, 4,  5, 'CUST041', 16,   2317.47,   37079.52),
('TXN5008', 20231208, 3,  2, 'CUST030',  9,  27469.99,  247229.91),
('TXN5009', 20230815, 3, 13, 'CUST020',  3,  58851.01,  176553.03),
('TXN5010', 20230604, 1,  4, 'CUST031', 15,  30187.24,  452808.60),
('TXN5011', 20231020, 5,  5, 'CUST045', 13,   2317.47,   30127.11),
('TXN5012', 20230521, 3,  6, 'CUST044', 13,  42343.15,  550460.95),
('TXN5013', 20230428, 5,  7, 'CUST015', 10,  43374.39,  433743.90),
('TXN5014', 20231118, 2,  4, 'CUST042',  5,  30187.24,  150936.20);
