# Assignment 02 — Database Systems & Modern Data Architecture

[![SQL](https://img.shields.io/badge/SQL-Relational%20DB-blue)](https://www.mysql.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-NoSQL-brightgreen)](https://www.mongodb.com/)
[![Data Warehouse](https://img.shields.io/badge/Data-Warehouse-orange)](https://en.wikipedia.org/wiki/Data_warehouse)
[![Vector DB](https://img.shields.io/badge/Vector-Database-purple)](https://www.pinecone.io/)
[![DuckDB](https://img.shields.io/badge/DuckDB-Data%20Lake-blueviolet)](https://duckdb.org/)
[![Python](https://img.shields.io/badge/Python-Data%20Processing-yellow)](https://www.python.org/)

**Student ID:** BITSOM_BA_25111017

---

## Project Overview

This project demonstrates the design and implementation of a modern, multi-layered data architecture for a retail data management system. The assignment explores six different data storage and processing paradigms — each chosen for specific workloads — and culminates in a capstone architecture design for a hospital AI system.

The datasets used throughout this project represent a realistic retail scenario, including customer orders, product catalogs, store transactions, and order line items stored across CSV, JSON, and Parquet formats.

---

## Technologies and Concepts Covered

- **Relational Databases (SQL):** Schema normalization to 3NF, anomaly analysis, complex SQL queries
- **NoSQL Document Databases (MongoDB):** Flexible schema design, document modeling, indexing
- **Data Warehousing:** Star schema design, ETL transformations, OLAP analytical queries
- **Vector Databases:** Sentence embeddings, cosine similarity search, semantic retrieval (RAG)
- **Data Lake & DuckDB:** Cross-format querying across CSV, JSON, and Parquet without pre-loading
- **Capstone Architecture:** Multi-system hospital AI platform design with justification

---

## System Architecture

```
flowchart TD
    A[Raw Datasets\nCSV / JSON / Parquet] --> B
    A --> C
    A --> D
    A --> E

    B[Part 1: Relational DB\nMySQL / PostgreSQL\n3NF Normalized Schema]
    C[Part 2: NoSQL\nMongoDB\nDocument Store]
    D[Part 3: Data Warehouse\nStar Schema\nOLAP Queries]
    E[Part 5: Data Lake\nDuckDB\nCross-Format Queries]

    D --> F[Part 4: Vector Database\nEmbeddings + Similarity Search]
    B --> G[Part 6: Capstone\nHospital AI Platform\nMulti-System Architecture]
    C --> G
    D --> G
    E --> G
    F --> G
```

---

## Repository Structure

```
assignment-02-BITSOM_BA_25111017/
│
├── README.md
│
├── datasets/
│   ├── orders_flat.csv          ← Used in Part 1 (RDBMS)
│   ├── retail_transactions.csv  ← Used in Part 3 (Data Warehouse)
│   ├── customers.csv            ← Used in Part 5 (Data Lake)
│   ├── orders.json              ← Used in Part 5 (Data Lake)
│   └── products.parquet         ← Used in Part 5 (Data Lake)
│
├── part1-rdbms/
│   ├── schema_design.sql        ← 3NF tables + INSERT statements
│   ├── queries.sql              ← 5 analytical SQL queries
│   └── normalization.md         ← Anomaly analysis + justification
│
├── part2-nosql/
│   ├── mongo_queries.js         ← 5 MongoDB operations
│   ├── sample_documents.json    ← 3 product documents
│   └── rdbms_vs_nosql.md        ← ACID vs BASE + CAP theorem analysis
│
├── part3-datawarehouse/
│   ├── star_schema.sql          ← fact_sales + 3 dimension tables
│   ├── dw_queries.sql           ← 3 OLAP queries
│   └── etl_notes.md             ← 3 ETL transformation decisions
│
├── part4-vector-db/
│   ├── embeddings_demo.ipynb    ← Colab notebook (executed with outputs)
│   └── vector_db_reflection.md  ← Vector DB use case analysis
│
├── part5-datalake/
│   ├── duckdb_queries.sql       ← 4 cross-format DuckDB queries
│   └── architecture_choice.md  ← Data Lake vs Warehouse vs Lakehouse
│
└── part6-capstone/
    ├── architecture_diagram.png ← Hospital AI system diagram
    └── design_justification.md  ← Storage choices + trade-offs
```

---

## Grading Breakdown

| Part | Topic | Marks |
|------|-------|-------|
| Part 1 | RDBMS — Schema Design & Queries | 25 |
| Part 2 | NoSQL — MongoDB | 15 |
| Part 3 | Data Warehouse — Star Schema & OLAP | 20 |
| Part 4 | Vector Databases — Embeddings & Similarity | 15 |
| Part 5 | Data Lake & DuckDB | 10 |
| Part 6 | Capstone Architecture Design | 15 |
| **Total** | | **100** |

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| 3NF normalization with separate `offices` table | Eliminates all three anomaly types found in `orders_flat.csv` |
| MongoDB for product catalog | Flexible schema handles Electronics/Clothing/Groceries attributes without ALTER TABLE |
| Star schema with surrogate keys | Enables fast OLAP aggregation across time, store, and product dimensions |
| `all-MiniLM-L6-v2` embeddings | Lightweight but accurate; 384-dimensional vectors ideal for semantic search |
| DuckDB for data lake queries | Zero-ETL, reads CSV/JSON/Parquet directly in SQL — ideal for lakehouse workloads |
| Data Lakehouse for hospital capstone | Only architecture handling structured + unstructured + streaming data in one platform |

---

## How to Run

### Part 1 — SQL (MySQL / PostgreSQL)
```bash
mysql -u root -p < part1-rdbms/schema_design.sql
mysql -u root -p your_db < part1-rdbms/queries.sql
```

### Part 2 — MongoDB
```bash
mongosh "mongodb://localhost:27017/ecommerce" < part2-nosql/mongo_queries.js
```

### Part 3 — Data Warehouse
```bash
mysql -u root -p < part3-datawarehouse/star_schema.sql
mysql -u root -p your_db < part3-datawarehouse/dw_queries.sql
```

### Part 4 — Vector DB (Google Colab)
Upload `part4-vector-db/embeddings_demo.ipynb` to [colab.research.google.com](https://colab.research.google.com) and run all cells.

### Part 5 — DuckDB
```bash
duckdb < part5-datalake/duckdb_queries.sql
```
