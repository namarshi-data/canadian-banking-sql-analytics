# Refinement Notes

This version was refined to make the project easier to evaluate as a SQL portfolio project for analyst, finance analyst, BI analyst, reporting analyst, risk analyst, and junior SQL developer roles.

## Added

- `docs/sql_topic_roadmap_beginner_to_advanced.md` — full beginner-to-advanced SQL roadmap with project mapping.
- `docs/sql_concepts_coverage.md` — expanded recruiter-friendly SQL coverage matrix.
- `sql/11_deduplication_examples.sql` — duplicate detection and safe deduplication review patterns.
- `sql/12_scd_type2_customer_risk_history.sql` — SCD Type 2 expire-and-insert demonstration using customer risk history.
- `sql/13_transaction_control_examples.sql` — transaction control examples using `BEGIN`, `ROLLBACK`, `SAVEPOINT`, and production-safe patterns.
- `sql/14_advanced_sql_patterns.sql` — optional advanced SQL examples including recursive CTEs, pivot/unpivot logic, lateral joins, arrays, JSONB output, and statistical summaries.
- `sql/run_advanced.sql` — orchestrates the optional advanced SQL examples separately from the main build.
- `make advanced` — runs `sql/run_advanced.sql` after the main build.

## Updated

- `README.md` now highlights the complete SQL breadth: beginner, intermediate, advanced, financial analytics, data engineering, data quality, performance, and governance.
- `PROJECT_SUMMARY.md` now documents the SQL topic coverage upgrade.
- `sql/run_all.sql` now runs the complete main build, analyst case studies, performance examples, reconciliation checks, and assertion-style data-quality checks, then points users to `sql/run_advanced.sql`.
- `Makefile` now routes `make all` through `sql/run_all.sql` and `make advanced` through `sql/run_advanced.sql` for cleaner orchestration.
- `sql/03_constraints_indexes.sql` is now safer to rerun by dropping existing project constraints before recreating them and using `CREATE INDEX IF NOT EXISTS`.
- `sql/12_scd_type2_customer_risk_history.sql` now uses the same risk-band vocabulary as the dataset.
- `sql/14_advanced_sql_patterns.sql` now uses the correct `dim_products.product_family` values: `Deposit`, `Card`, `Loan`, and `Wealth`.

## Cleaned for GitHub

- The refined ZIP excludes local `.git/` metadata.
- The refined ZIP excludes Python `__pycache__/` files.
