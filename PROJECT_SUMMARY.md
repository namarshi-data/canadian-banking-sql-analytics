# Project Summary

## Project title

**Canadian Big 5 Banking SQL Analytics**

## One-line summary

A deployment-ready PostgreSQL portfolio project analyzing synthetic Canadian banking data across customer behaviour, branch performance, risk, fraud, campaigns, loans, cards, transactions, and service operations.

## Business value

The project simulates the work expected from a finance, banking, data, BI, or reporting analyst in Canada. It turns raw operational banking tables into trusted analytics views and solves practical business questions with SQL.

## What makes it professional

- Realistic star-schema-style model with dimensions, facts, and a bridge table.
- PostgreSQL deployment using Docker Compose.
- Typed DDL, constraints, indexes, and data-quality checks.
- Reusable business views and materialized views.
- Advanced SQL case studies covering CTEs, window functions, ranking, cohort analysis, rolling trends, segmentation, reconciliation, and exception monitoring.
- Documentation designed for recruiter review.
- Synthetic data disclaimer to avoid confidentiality concerns.

## Main analyst themes

1. Institution performance and deposit growth
2. Branch target attainment
3. Customer 360 analytics
4. Credit/card risk monitoring
5. Loan delinquency analysis
6. Fraud alert operations
7. Campaign conversion and ROI
8. Service SLA and operational efficiency
9. Data quality and reconciliation controls
10. Executive KPI reporting


## Validation status

- Reconciliation checks pass for all 22 tables: 22 passed, 0 failed.
- Assertion-style data quality checks pass: 9 passed, 0 failed.
- `dim_date` is intentionally enriched during load to cover valid transaction dates outside the original seed calendar, while core fact tables reconcile exactly to their source CSV row counts.


## SQL Topic Coverage Upgrade

This repository now includes a complete beginner-to-advanced SQL roadmap in `docs/sql_topic_roadmap_beginner_to_advanced.md`. The roadmap maps core SQL, intermediate analyst SQL, advanced SQL, data engineering SQL, financial analytics SQL, data quality, reconciliation, SCD Type 2 logic, transaction control, security, and dashboard-ready reporting views back to concrete project files.

Additional optional SQL scripts were added for recruiter/interview review:

- `sql/11_deduplication_examples.sql` — duplicate detection and safe deduplication patterns.
- `sql/12_scd_type2_customer_risk_history.sql` — SCD Type 2 expire-and-insert history pattern.
- `sql/13_transaction_control_examples.sql` — `BEGIN`, `COMMIT`, `ROLLBACK`, and `SAVEPOINT` patterns.
- `sql/14_advanced_sql_patterns.sql` — recursive CTEs, pivots/unpivots, lateral joins, arrays, JSONB, and statistical summaries.
- `sql/run_all.sql` — repeatable main build orchestration covering setup, loading, constraints, marts, functions, security, case studies, performance examples, reconciliation, and assertions.
- `sql/run_advanced.sql` — optional advanced SQL orchestration for interview/recruiter review.
