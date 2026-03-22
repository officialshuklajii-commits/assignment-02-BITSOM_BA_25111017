# Part 1 — RDBMS Normalization

## Anomaly Analysis

The file `orders_flat.csv` is a fully denormalized spreadsheet with 186 rows and 15 columns. All customer, product, sales representative, and order information is stored in a single table. This design introduces three classic data anomalies, each demonstrated with specific rows from the dataset.

---

### Insert Anomaly

**Definition:** An insert anomaly occurs when a new, valid piece of data cannot be recorded in the database without simultaneously inserting unrelated and potentially fabricated data.

**Example from `orders_flat.csv`:**
Suppose the company hires a new sales representative **SR04 – Meera Patel** (`meera@corp.com`) assigned to the Hyderabad office. Because every row in the flat table requires a valid `order_id`, `customer_id`, and `product_id`, there is no way to record SR04's details until she places her first order. The company's HR records are valid, but the database cannot store them. This means the data about the new employee is lost until an order is created — a direct insert anomaly caused by the absence of a standalone `sales_reps` table.

---

### Update Anomaly

**Definition:** An update anomaly occurs when the same fact is stored in multiple rows, so changing it in one row without updating all rows leaves the database in an inconsistent state.

**Example from `orders_flat.csv`:**
Sales rep **SR01 – Deepak Joshi** appears across many rows. In the majority of rows, the `office_address` column reads:
`"Mumbai HQ, Nariman Point, Mumbai - 400021"`

However, in **row index 37**, the same address is stored as:
`"Mumbai HQ, Nariman Pt, Mumbai - 400021"` — with "Pt" instead of "Point."

This inconsistency exists because the address is repeated on every single order row for SR01. A single missed update during a data entry correction caused the discrepancy. If Deepak Joshi's office were to move, every one of his ~60 order rows would need to be updated. Missing even one creates a permanent inconsistency.

---

### Delete Anomaly

**Definition:** A delete anomaly occurs when deleting a row of data unintentionally destroys other, unrelated information that was embedded in the same row.

**Example from `orders_flat.csv`:**
Customer **C008 – Kavya Rao** (`kavya@gmail.com`, Hyderabad) appears in only a small number of order rows. If all of Kavya's orders are deleted — for example, due to full returns, order cancellations, or a data cleanup process — **all knowledge of Kavya as a customer is permanently erased** from the database. Her customer ID, email address, and city are stored only as columns within order rows, not in any dedicated customer record. There is no separate `customers` table to preserve her profile independently of her order history.

---

## Normalization Justification

The argument that keeping everything in one table is "simpler" fails when examined against the actual data in `orders_flat.csv`. The flat file demonstrates all three classic anomalies, and each one directly harms business operations.

Sales rep SR01 – Deepak Joshi has his office address repeated across dozens of rows, which already produced two different spellings in the same dataset — "Nariman Point" versus "Nariman Pt." In a normalized `sales_reps` table linked to an `offices` table, his address exists in exactly one row. A single `UPDATE` statement corrects it everywhere, and inconsistency becomes structurally impossible.

Customer C008 – Kavya Rao exists in the database only as long as she has active orders. Delete her returned orders and her email address, city, and customer ID vanish permanently from the system. A normalized `customers` table retains her record regardless of her order history — her identity as a customer is preserved independently of any transaction.

For products, a new item like P009 — a Mechanical Keyboard — cannot be recorded in the catalog until at least one customer orders it. This is a direct insert anomaly that prevents the business from managing its product catalog accurately. A standalone `products` table solves this completely: products exist independently of whether they have been sold.

Normalization to 3NF stores every fact exactly once. Customers in `customers`, products in `products`, offices in `offices`, sales reps in `sales_reps`, and transactions in `orders`. Joins reconstruct the full picture efficiently with indexed foreign keys. The apparent "simplicity" of a flat table is illusory — it transfers data quality responsibility away from the database and into every application, report, and ETL pipeline that touches the data, multiplying the risk of errors at every step. For a business that intends to grow, 3NF is not over-engineering; it is the only sound foundation.
