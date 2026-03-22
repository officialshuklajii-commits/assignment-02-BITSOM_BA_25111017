# Part 3 — Data Warehouse ETL Notes

## ETL Decisions

The raw file `retail_transactions.csv` (300 rows) contained three categories of data quality issues that had to be resolved before loading into the star schema. Each decision is documented below.

---

### Decision 1 — Date Format Standardisation

**Problem:** The `date` column in `retail_transactions.csv` contains dates in at least three different formats within the same column: ISO format (`2023-02-05`), day-first with slashes (`29/08/2023`), and day-first with hyphens (`12-12-2023`). This means the column cannot be directly cast to a SQL `DATE` type — different rows would fail parsing depending on the database engine's date parser, potentially silently inserting wrong dates (e.g., `12-08-2023` could be read as August 12 or December 8).

**Resolution:** During the ETL transformation step, all date values were normalised to ISO 8601 format (`YYYY-MM-DD`) using Python's `dateutil.parser.parse()` function, which correctly handles all three variants without ambiguity. The standardised dates were then used to generate integer `date_key` values in `YYYYMMDD` format (e.g., `20230829`) for loading into `dim_date`. This integer format enables fast range scans and sorting without requiring date-type casting at query time.

---

### Decision 2 — Product Category Casing Standardisation

**Problem:** The `category` column contains the same category under multiple inconsistent spellings across 300 rows: `"electronics"` (all lowercase), `"Electronics"` (title case), `"Grocery"` (singular), and `"Groceries"` (plural). Grouping by category in analytical queries — such as Q1 (revenue by category per month) — produces split results. Electronics revenue, for example, appears as two separate rows, making any aggregation incorrect and BI reports misleading.

**Resolution:** All category values were normalised using `str.strip().title()` in Python to convert to consistent Title Case, followed by a manual mapping to unify `"Grocery"` → `"Groceries"`. The standardised value was stored in `dim_product.category`. This ensures that all OLAP queries aggregate correctly under exactly three distinct categories: `Electronics`, `Clothing`, and `Groceries`. The raw original inconsistent values were discarded after transformation.

---

### Decision 3 — NULL store_city Resolution

**Problem:** The `store_city` column contains 19 NULL values spread across multiple store names (e.g., `"Mumbai Central"` with NULL city, `"Chennai Anna"` with NULL city, `"Delhi South"` with NULL city). A NULL city in the `dim_store` dimension would make geographic analysis queries — such as revenue by city or zone — incomplete and unreliable. Dropping these 19 rows would reduce the fact table by over 6% and introduce selection bias in monthly trends.

**Resolution:** A deterministic lookup mapping was constructed from the non-NULL rows in the dataset: each unique `store_name` was mapped to its known `store_city` (e.g., `"Mumbai Central"` → `"Mumbai"`, `"Chennai Anna"` → `"Chennai"`). Since store names were consistent across all rows, this mapping was unambiguous. The NULL `store_city` values were then back-filled using this mapping before loading into `dim_store`. No rows were dropped. This approach preserved all 300 transactions while ensuring the store dimension is complete and consistent.
