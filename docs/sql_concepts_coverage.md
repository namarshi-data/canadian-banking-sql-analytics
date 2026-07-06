# SQL Concepts Coverage

This project is intentionally designed to demonstrate the SQL capabilities requested in Canadian analyst, BI analyst, reporting analyst, finance analyst, risk analyst, and junior SQL developer job postings.

For the complete beginner-to-advanced roadmap, see: [`docs/sql_topic_roadmap_beginner_to_advanced.md`](sql_topic_roadmap_beginner_to_advanced.md).

---

## Executive Coverage Summary

| Area | Coverage | Evidence |
|---|---:|---|
| Core SQL querying | Strong | `answers/01_core_sql_questions.sql`, `sql/10_analyst_case_studies.sql` |
| Joins and relational thinking | Strong | `sql/05_business_views.sql`, star-schema model |
| Aggregations and KPIs | Strong | `sql/05_business_views.sql`, `reports/executive_insights.md` |
| CTEs and readable query design | Strong | `sql/10_analyst_case_studies.sql` |
| Window functions | Strong | `answers/02_advanced_sql_window_functions.sql`, `sql/10_analyst_case_studies.sql` |
| Data cleaning and standardization | Strong | `sql/02_load_csv_postgres.sql` |
| Data-quality testing | Strong | `sql/04_data_quality_tests.sql`, `tests/data_quality_assertions.sql` |
| Reconciliation | Strong | `tests/reconciliation_checks.sql` |
| Deduplication | Strong | `sql/11_deduplication_examples.sql` |
| Star schema and dimensional modeling | Strong | `sql/01_create_tables.sql`, `docs/erd.md` |
| SCD Type 2 history handling | Strong | `fact_customer_risk_history`, `sql/12_scd_type2_customer_risk_history.sql` |
| ETL / ELT loading | Strong | `sql/02_load_csv_postgres.sql`, Docker, Makefile |
| Stored functions and procedures | Strong | `sql/07_functions_procedures.sql` |
| Transactions and safe changes | Strong | `sql/13_transaction_control_examples.sql` |
| Security and permissions | Strong | `sql/08_security_roles.sql` |
| Query optimization | Strong | `sql/03_constraints_indexes.sql`, `sql/09_performance_tuning_examples.sql` |
| Dashboard-ready reporting | Strong | `mart` views and materialized views |

---

## Recruiter-Friendly Job Skills Matrix

| Job skill | Where implemented | Why it matters |
|---|---|---|
| Joins | `sql/05_business_views.sql`, `sql/10_analyst_case_studies.sql` | Combines customer, account, product, branch, institution, campaign, loan, fraud, and service data. |
| Aggregations | `sql/05_business_views.sql`, reports | Produces balances, counts, rates, totals, averages, and executive KPIs. |
| CTEs | Case studies and dedup examples | Makes complex analysis readable, testable, and interview-ready. |
| Window functions | `answers/02_advanced_sql_window_functions.sql`, case studies | Supports ranking, prior-period comparison, rolling metrics, deciles, and deduplication. |
| `CASE WHEN` logic | Views, functions, case studies | Converts raw fields into business categories such as risk tier, delinquency bucket, and SLA flag. |
| Date calculations | `dim_date`, loan/service/campaign facts | Supports month-end reporting, aging, rolling windows, and trend analysis. |
| Data cleaning | `sql/02_load_csv_postgres.sql` | Standardizes date keys, score labels, and SLA flags before reporting. |
| Deduplication | `sql/11_deduplication_examples.sql` | Shows duplicate detection, review, and safe deduplication patterns. |
| Subqueries | Functions, tests, case studies | Demonstrates flexible analytical query design. |
| Views | `sql/05_business_views.sql` | Creates reusable business logic instead of one-off queries. |
| KPI reporting | `mart` schema views | Provides business-ready outputs for finance, risk, branch, and service dashboards. |
| Financial calculations | Loan, card, balance, fraud, and campaign logic | Shows practical finance analytics: interest, fees, utilization, loss, conversion, and target attainment. |
| Data quality checks | `sql/04_data_quality_tests.sql`, `tests/` | Demonstrates production-style control thinking. |
| Reconciliation queries | `tests/reconciliation_checks.sql` | Validates source-to-target row counts and load completeness. |
| Indexing basics | `sql/03_constraints_indexes.sql` | Supports joins, filtering, and dashboard workloads. |
| Query optimization | `sql/09_performance_tuning_examples.sql` | Uses `EXPLAIN ANALYZE`, composite indexes, materialized views, and partitioning patterns. |
| Star schema design | `dim_`, `fact_`, bridge tables | Shows analytics-ready dimensional modeling. |
| Fact and dimension tables | 22-table model | Separates business entities, events, balances, targets, and transactions. |
| SCD Type 2 logic | `fact_customer_risk_history`, `sql/12_scd_type2_customer_risk_history.sql` | Preserves customer risk history with effective dating and current flags. |
| ETL / ELT pipelines | `sql/02_load_csv_postgres.sql`, `sql/run_all.sql` | Loads raw CSVs into typed PostgreSQL tables and performs standardization through a reproducible orchestration script. |
| Stored procedures | `audit.refresh_reporting_marts()` | Demonstrates operational refresh automation. |
| Transactions | `sql/13_transaction_control_examples.sql` | Shows safe use of `BEGIN`, `COMMIT`, `ROLLBACK`, and `SAVEPOINT`. |
| Security and permissions | `sql/08_security_roles.sql` | Applies least-privilege reporting access patterns. |
| Dashboard-ready reporting views | `sql/05_business_views.sql`, `sql/06_materialized_views.sql` | Makes the project Power BI / Tableau ready. |
| Business problem solving with SQL | `sql/10_analyst_case_studies.sql`, reports | Converts banking questions into measurable insights. |

---

## SQL File Map

| File | Primary purpose |
|---|---|
| `sql/00_setup.sql` | Create schemas and setup foundation. |
| `sql/01_create_tables.sql` | Create typed banking tables. |
| `sql/02_load_csv_postgres.sql` | Load synthetic CSVs and standardize reporting fields. |
| `sql/03_constraints_indexes.sql` | Add primary keys, business keys, checks, foreign keys, and indexes. |
| `sql/04_data_quality_tests.sql` | Profile data-quality exceptions and business-valid nulls. |
| `sql/05_business_views.sql` | Create reusable mart views for KPIs and dashboards. |
| `sql/06_materialized_views.sql` | Create performance-oriented materialized views. |
| `sql/07_functions_procedures.sql` | Create reusable functions and refresh procedure. |
| `sql/08_security_roles.sql` | Create governed access roles and grants. |
| `sql/09_performance_tuning_examples.sql` | Show query-plan, indexing, materialized view, and partitioning patterns. |
| `sql/10_analyst_case_studies.sql` | Solve business questions with intermediate and advanced SQL. |
| `sql/11_deduplication_examples.sql` | Demonstrate duplicate detection and safe deduplication patterns. |
| `sql/12_scd_type2_customer_risk_history.sql` | Demonstrate SCD Type 2 expire-and-insert logic. |
| `sql/13_transaction_control_examples.sql` | Demonstrate safe transaction control and savepoints. |
| `sql/14_advanced_sql_patterns.sql` | Demonstrate optional advanced patterns such as recursive CTEs, pivots, lateral joins, arrays, and statistics. |
| `sql/run_all.sql` | Orchestrate the complete main build, case studies, performance examples, reconciliation, and assertion checks. |
| `sql/run_advanced.sql` | Orchestrate optional advanced SQL examples after the main build. |

---

## Notes on Topics Not Overused in the Main Build

Some advanced database topics are documented or shown as optional examples rather than forced into the production build:

- **Dynamic SQL** is not executed because static SQL is safer and easier for recruiters to review.
- **Triggers** are not used because this project favors explicit, transparent batch logic and audit checks.
- **JSON/geospatial/full-text search** are modern extensions, but they are not central to this structured banking CSV dataset.
- **Partitioning** is shown as a production pattern, but the portfolio dataset is small enough that physical partitioning is not required.
