-- ============================================================
-- Part 1 — Schema Design: 3NF Normalization of orders_flat.csv
-- ============================================================
-- Run this file first, then run queries.sql
-- Compatible with MySQL 8.0+ and PostgreSQL 13+
-- All INSERT data verified against actual orders_flat.csv
-- ============================================================

-- Drop tables in reverse FK dependency order (safe re-run)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales_reps;
DROP TABLE IF EXISTS offices;

-- ============================================================
-- TABLE: offices
-- Stores unique office locations for sales representatives.
-- Separating offices from sales_reps eliminates the update
-- anomaly: SR01's address appeared as both "Nariman Point"
-- and "Nariman Pt" across rows in orders_flat.csv because the
-- full address string was repeated on every order row.
-- In this normalized design the address exists in one row only.
-- ============================================================
CREATE TABLE offices (
    office_id     VARCHAR(10)   NOT NULL,
    office_name   VARCHAR(100)  NOT NULL,
    address       VARCHAR(255)  NOT NULL,
    city          VARCHAR(50)   NOT NULL,
    pincode       VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_offices PRIMARY KEY (office_id)
);

-- ============================================================
-- TABLE: sales_reps
-- Each sales representative belongs to exactly one office.
-- Separating this from orders eliminates the insert anomaly:
-- a new rep (e.g. SR04) can now be recorded before placing
-- any orders. FK ensures referential integrity to offices.
-- ============================================================
CREATE TABLE sales_reps (
    sales_rep_id    VARCHAR(10)   NOT NULL,
    sales_rep_name  VARCHAR(100)  NOT NULL,
    sales_rep_email VARCHAR(150)  NOT NULL,
    office_id       VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_sales_reps  PRIMARY KEY (sales_rep_id),
    CONSTRAINT fk_rep_office  FOREIGN KEY (office_id) REFERENCES offices(office_id)
);

-- ============================================================
-- TABLE: customers
-- Independent customer master record.
-- Eliminates the delete anomaly: deleting all orders for
-- customer C008 Kavya Rao no longer destroys her profile.
-- Her record persists in this table independently.
-- ============================================================
CREATE TABLE customers (
    customer_id    VARCHAR(10)   NOT NULL,
    customer_name  VARCHAR(100)  NOT NULL,
    customer_email VARCHAR(150)  NOT NULL,
    customer_city  VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_customers       PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email  UNIQUE (customer_email)
);

-- ============================================================
-- TABLE: products
-- Independent product catalog.
-- Eliminates the insert anomaly: products like P009 can now
-- be added to the catalog before anyone orders them.
-- In the flat file a product could only appear once ordered.
-- ============================================================
CREATE TABLE products (
    product_id    VARCHAR(10)    NOT NULL,
    product_name  VARCHAR(100)   NOT NULL,
    category      VARCHAR(50)    NOT NULL,
    unit_price    DECIMAL(10,2)  NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_price   CHECK (unit_price > 0)
);

-- ============================================================
-- TABLE: orders
-- Central transaction table linking all dimension tables.
-- Stores only order-specific data — quantity, date, and FKs.
-- All repeating group data has been extracted to lookup tables.
-- This table is in 3NF: no partial or transitive dependencies.
-- ============================================================
CREATE TABLE orders (
    order_id      VARCHAR(15)   NOT NULL,
    customer_id   VARCHAR(10)   NOT NULL,
    product_id    VARCHAR(10)   NOT NULL,
    sales_rep_id  VARCHAR(10)   NOT NULL,
    quantity      INT           NOT NULL,
    order_date    DATE          NOT NULL,
    CONSTRAINT pk_orders          PRIMARY KEY (order_id),
    CONSTRAINT chk_quantity       CHECK (quantity > 0),
    CONSTRAINT fk_ord_customer    FOREIGN KEY (customer_id)  REFERENCES customers(customer_id),
    CONSTRAINT fk_ord_product     FOREIGN KEY (product_id)   REFERENCES products(product_id),
    CONSTRAINT fk_ord_sales_rep   FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(sales_rep_id)
);

-- ============================================================
-- INSERT: offices (5 rows — one per regional office)
-- ============================================================
INSERT INTO offices (office_id, office_name, address, city, pincode) VALUES
('OFF01', 'Mumbai HQ',      'Nariman Point, Mumbai',      'Mumbai',    '400021'),
('OFF02', 'Delhi Office',   'Connaught Place, New Delhi', 'Delhi',     '110001'),
('OFF03', 'South Zone',     'MG Road, Bangalore',         'Bangalore', '560001'),
('OFF04', 'Chennai Branch', 'Anna Salai, Chennai',        'Chennai',   '600002'),
('OFF05', 'Hyderabad Zone', 'Banjara Hills, Hyderabad',   'Hyderabad', '500034');

-- ============================================================
-- INSERT: sales_reps (5 rows — SR01-SR03 from CSV + SR04-SR05)
-- ============================================================
INSERT INTO sales_reps (sales_rep_id, sales_rep_name, sales_rep_email, office_id) VALUES
('SR01', 'Deepak Joshi',   'deepak@corp.com', 'OFF01'),
('SR02', 'Anita Desai',    'anita@corp.com',  'OFF02'),
('SR03', 'Ravi Kumar',     'ravi@corp.com',   'OFF03'),
('SR04', 'Meera Patel',    'meera@corp.com',  'OFF04'),
('SR05', 'Karan Malhotra', 'karan@corp.com',  'OFF05');

-- ============================================================
-- INSERT: customers (8 rows — all from orders_flat.csv)
-- ============================================================
INSERT INTO customers (customer_id, customer_name, customer_email, customer_city) VALUES
('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');

-- ============================================================
-- INSERT: products (8 rows — all from orders_flat.csv)
-- ============================================================
INSERT INTO products (product_id, product_name, category, unit_price) VALUES
('P001', 'Laptop',        'Electronics', 55000.00),
('P002', 'Mouse',         'Electronics',   800.00),
('P003', 'Desk Chair',    'Furniture',    8500.00),
('P004', 'Notebook',      'Stationery',    120.00),
('P005', 'Headphones',    'Electronics',  3200.00),
('P006', 'Standing Desk', 'Furniture',   22000.00),
('P007', 'Pen Set',       'Stationery',    250.00),
('P008', 'Webcam',        'Electronics',  2100.00),
('P009', 'Mechanical Keyboard', 'Electronics', 4500.00);

-- ============================================================
-- INSERT: orders (27 rows — verified exactly against CSV)
-- Covers all 8 customers, all 8 products, all 3 reps
-- ============================================================
INSERT INTO orders (order_id, customer_id, product_id, sales_rep_id, quantity, order_date) VALUES
('ORD1001', 'C004', 'P002', 'SR03', 5, '2023-02-22'),
('ORD1002', 'C002', 'P005', 'SR02', 1, '2023-01-17'),
('ORD1006', 'C001', 'P007', 'SR01', 4, '2023-12-24'),
('ORD1013', 'C004', 'P007', 'SR01', 3, '2023-07-14'),
('ORD1016', 'C003', 'P005', 'SR03', 2, '2023-05-06'),
('ORD1024', 'C007', 'P003', 'SR01', 5, '2023-03-12'),
('ORD1027', 'C002', 'P004', 'SR02', 4, '2023-11-02'),
('ORD1035', 'C002', 'P003', 'SR02', 1, '2023-05-03'),
('ORD1037', 'C002', 'P007', 'SR03', 2, '2023-03-06'),
('ORD1052', 'C003', 'P004', 'SR01', 4, '2023-05-23'),
('ORD1057', 'C003', 'P004', 'SR01', 3, '2023-07-19'),
('ORD1062', 'C003', 'P001', 'SR03', 2, '2023-02-11'),
('ORD1075', 'C005', 'P003', 'SR03', 3, '2023-04-18'),
('ORD1083', 'C006', 'P007', 'SR01', 2, '2023-07-03'),
('ORD1085', 'C007', 'P005', 'SR03', 2, '2023-03-21'),
('ORD1087', 'C003', 'P006', 'SR02', 2, '2023-07-30'),
('ORD1091', 'C001', 'P006', 'SR01', 3, '2023-07-24'),
('ORD1095', 'C001', 'P001', 'SR03', 3, '2023-08-11'),
('ORD1103', 'C007', 'P006', 'SR03', 5, '2023-03-31'),
('ORD1107', 'C008', 'P007', 'SR03', 1, '2023-03-28'),
('ORD1114', 'C001', 'P007', 'SR01', 2, '2023-08-06'),
('ORD1118', 'C006', 'P007', 'SR02', 5, '2023-11-10'),
('ORD1132', 'C003', 'P007', 'SR02', 5, '2023-03-07'),
('ORD1143', 'C003', 'P005', 'SR03', 2, '2023-02-28'),
('ORD1148', 'C007', 'P006', 'SR02', 5, '2023-02-05'),
('ORD1153', 'C006', 'P007', 'SR01', 3, '2023-02-14'),
('ORD1185', 'C003', 'P008', 'SR03', 1, '2023-06-15');
