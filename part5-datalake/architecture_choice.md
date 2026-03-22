# Part 5 — Data Lake Architecture

## Architecture Recommendation

I would recommend a **Data Lakehouse** architecture for this food delivery startup, for three specific reasons.

**1. The data is fundamentally multi-modal.** A traditional Data Warehouse handles only structured tabular data — it cannot store GPS logs (time-series), customer text reviews (unstructured), or menu images (binary). A pure Data Lake stores all raw formats but lacks schema enforcement and ACID guarantees needed for payment transactions. The Data Lakehouse — built on Delta Lake or Apache Iceberg on object storage — provides both: raw heterogeneous storage with SQL query capability and ACID transactions on top.

**2. Both real-time analytics and batch ML workloads are required.** Payment fraud detection needs low-latency, consistent reads — a raw Data Lake cannot guarantee this. Simultaneously, GPS logs and reviews must feed ML models as large batch jobs. The Data Lakehouse supports both in one system: ACID-backed queries for operations and open Parquet formats for ML training pipelines.

**3. Schema evolution is critical for a fast-growing startup.** New restaurant categories, delivery zones, and payment methods are added constantly. A rigid Data Warehouse requires costly migrations. Delta Lake and Iceberg support schema evolution natively — new columns are added without breaking existing queries.

A pure Data Warehouse sacrifices raw data fidelity. A pure Data Lake fails on governance and payment-level consistency. The Data Lakehouse is the only architecture that handles GPS logs, text reviews, transactions, and menu images under one governed, scalable platform.
