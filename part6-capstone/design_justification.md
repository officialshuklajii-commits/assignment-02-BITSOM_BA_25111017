# Part 6 — Capstone Architecture Design

## Storage Systems

The hospital network has four goals, each requiring a distinct storage technology.

**Goal 1 — Predict patient readmission risk:** A **Data Lakehouse** (Delta Lake on AWS S3) is the right choice. Historical treatment records, lab results, and discharge summaries are semi-structured datasets best stored in open columnar Parquet format for ML feature engineering. The Lakehouse layer adds schema versioning and ACID guarantees so model training pipelines are reproducible and auditable.

**Goal 2 — Plain-English patient history queries:** A **Vector Database** (Pinecone, Weaviate, or pgvector) stores embeddings of clinical notes and diagnoses. When a doctor asks "Has this patient had a cardiac event?", the query is embedded and matched semantically against stored vectors using approximate nearest-neighbour search — enabling retrieval that keyword search cannot achieve across varied medical terminology.

**Goal 3 — Monthly management reports:** A **Data Warehouse** (Snowflake or Amazon Redshift) with a pre-aggregated star schema serves fast analytical queries for BI tools such as Power BI. Data is loaded nightly via ETL from OLTP and Lakehouse sources, enabling sub-second query performance over millions of historical records.

**Goal 4 — Real-time ICU vitals streaming:** A **Time-Series Database** (InfluxDB or Apache Cassandra behind Kafka) handles high-frequency writes of vitals — heart rate, blood pressure, SpO2 — from ICU monitors, with time-windowed queries and automated retention policies.

## OLTP vs OLAP Boundary

The **OLTP boundary** covers live clinical operations: the hospital EHR system (PostgreSQL), the ICU streaming pipeline, and patient admission and discharge workflows. These require ACID compliance, row-level access, and low-latency writes.

The **OLAP boundary** begins at the ETL layer — Apache Airflow extracts data from OLTP on a scheduled basis and loads it into the Data Warehouse and Data Lakehouse. No reporting or ML workload queries OLTP systems directly, protecting clinical performance. The Vector Database occupies a middle position: it is populated asynchronously from clinical notes via a scheduled embedding pipeline, but it serves near-real-time semantic queries at query time. This makes it analytically oriented in its read pattern but operationally oriented in its latency requirements.

## Trade-offs

**Trade-off: Operational complexity across four storage systems.** A broken ETL pipeline between the EHR and the Data Lakehouse could cause ML models to train on stale data, silently degrading readmission predictions without any immediate alert to clinicians.

**Mitigation:** Adopt a unified managed platform such as **Databricks** or **Microsoft Fabric**, which provides Lakehouse, warehouse, and streaming in one governed service. Implement a data quality framework (Great Expectations) for pipeline validation and a centralised data catalogue (Apache Atlas) for schema consistency and lineage tracking across all layers. These measures do not eliminate complexity but make it observable, manageable, and recoverable without manual intervention.
