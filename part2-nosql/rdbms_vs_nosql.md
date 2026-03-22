# Part 2 — NoSQL vs RDBMS

## Database Recommendation

For the core **patient management system**, I would recommend **MySQL** (or any ACID-compliant RDBMS). The reasoning is rooted in both the CAP theorem and the nature of healthcare data.

Healthcare data must be **consistent and durable above all else**. A patient's allergy record must never be partially written; a prescription update must fully commit or fully roll back. These are textbook ACID requirements — Atomicity, Consistency, Isolation, and Durability. Under the CAP theorem, MySQL prioritises **Consistency and Partition Tolerance (CP)**: during a network partition, it refuses stale reads rather than risk returning incorrect clinical data. For patient safety, this is the correct trade-off.

MongoDB follows a **BASE** model — Basically Available, Soft state, Eventual consistency. Although recent versions support multi-document transactions, MongoDB is architecturally optimised for availability over strict consistency in distributed setups. For a doctor reading a patient's allergy list, eventual consistency is clinically unacceptable — the data must always reflect the absolute latest state.

Additionally, patient data has well-defined relational structure: patients link to doctors, appointments, prescriptions, lab results, and insurance records. Relational joins and foreign key constraints make MySQL the natural fit. HIPAA compliance also aligns more naturally with auditable, schema-enforced RDBMS designs.

**Would the answer change for a fraud detection module?** Yes, partially. Fraud detection processes high-velocity, semi-structured event streams — login attempts, transaction patterns, device fingerprints — that vary in shape per event. MongoDB's flexible schema and horizontal scalability handle this well. Fraud detection can also tolerate slightly stale reads, making BASE semantics acceptable. I would recommend a **hybrid architecture**: MySQL for core patient records where strict consistency is non-negotiable, and MongoDB or Apache Cassandra for the fraud detection module where throughput and schema flexibility take priority.
