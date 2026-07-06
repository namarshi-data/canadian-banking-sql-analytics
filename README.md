# Canadian Big 5 Banking SQL Analytics

**PostgreSQL portfolio project using synthetic Canadian banking data to analyze customer risk, fraud alerts, branch performance, loans, cards, campaigns, service SLAs, and data quality with advanced SQL.**

This project is built around a synthetic Canadian banking dataset covering the Big 5 banks plus National Bank as a D-SIB benchmark. It is designed to prove that I can work beyond simple `SELECT` queries: data modelling, loading, referential integrity, data-quality testing, reconciliation, deduplication, financial KPI reporting, operational analytics, risk monitoring, campaign analysis, fraud analytics, service SLA analysis, window functions, CTEs, materialized views, stored functions, procedures, SCD Type 2 history logic, transaction control, indexing, query optimization, security permissions, and deployment-ready PostgreSQL execution.

> Dataset status: **synthetic / portfolio-safe / no real customers / no confidential bank data**.

---

## Why this project is relevant for Canadian analyst roles

Canadian analyst postings commonly ask for SQL, Power BI, data quality, reporting automation, financial/risk analytics, stakeholder communication, and the ability to turn raw data into business recommendations. This project was designed to match those expectations by using a realistic banking star schema and solving analyst-style questions across deposits, cards, loans, fraud, campaigns, branch targets, service operations, and customer risk.

The project is intentionally **SQL-first**. Python is only used for optional local validation scripts and is marked as vendored in `.gitattributes` so GitHub presents this repository as a SQL portfolio project.

---

## Business scenario

A Canadian banking analytics team needs a reusable SQL analytics layer to answer questions such as:

- Which institutions and provinces are driving deposit balance growth?
- Which branches are missing deposit, origination, new-account, or SLA targets?
- Which customers show elevated credit risk based on utilization, delinquency, and credit score history?
- Which campaigns generate the best conversion and estimated revenue?
- Which fraud-alert categories have high confirmed-loss rates or false-positive pressure?
- Which service channels and priorities create SLA risk?
- Which data-quality issues could affect executive reporting?

---

## Dataset overview

| Area | Tables |
|---|---|
| Customer and geography | `dim_customers`, `dim_geography`, `fact_customer_risk_history` |
| Institutions and branches | `dim_institutions`, `dim_branches`, `fact_branch_monthly_targets` |
| Products and accounts | `dim_products`, `fact_accounts`, `bridge_account_customers`, `fact_monthly_account_balances` |
| Transactions and cards | `fact_transactions`, `fact_card_statements` |
| Lending | `fact_loans`, `fact_loan_payments`, `dim_interest_rates` |
| Campaigns and service | `dim_campaigns`, `fact_campaign_contacts`, `fact_service_requests` |
| Fraud, tax, FX, calendar | `fact_fraud_alerts`, `dim_tax_rates`, `fact_fx_rates`, `dim_date` |

**Source rows:** 514,632 across **22 CSV tables**. During load, `dim_date` is enriched from 1,096 to 1,099 rows so all valid transaction dates resolve to the conformed date dimension.

## Data modelling and quality notes

This project intentionally keeps two business-valid null scenarios instead of forcing artificial placeholder values:

- `fact_campaign_contacts.customer_id` is nullable because campaign contact records may represent prospects, anonymous leads, or pre-acquisition marketing outreach. These rows are retained for campaign-level performance analysis, while populated `customer_id` values support customer-level conversion and cross-sell analysis.
- `fact_customer_risk_history.credit_score` is nullable because some customers may be new-to-credit, have limited bureau history, or be temporarily unscoreable. These rows are retained and classified under the `No Score` segment instead of being removed.
- `fact_transactions.date_key` is standardized from `transaction_date` during the PostgreSQL load step, and the conformed `dim_date` table is extended for valid transaction dates outside the original seed calendar range. This preserves transaction history while keeping time-series joins reliable.
- `fact_service_requests.sla_breached_flag` is recalculated during load from the business rule `resolution_hours > sla_target_hours`, so SLA reporting uses one consistent definition.

The data-quality layer profiles business-valid exceptions separately, validates populated keys/scores, and documents whether each finding is `Critical`, `Review`, or `Monitor`. Critical checks are expected to return zero exceptions after the reproducible load process.

## Validation status

The latest clean build passed both reconciliation and assertion-style data-quality checks.

| Validation area | Result |
|---|---:|
| Reconciled tables checked | 22 |
| Reconciled tables passed | 22 |
| Reconciled tables failed | 0 |
| Data-quality assertions passed | 9 |
| Data-quality assertions failed | 0 |

`dim_date` uses a minimum row-count reconciliation rule because it is intentionally enriched during load to cover valid transaction dates outside the original seed calendar. All core facts still reconcile exactly to their generated CSV source rows.

---

## Repository structure

```text
canadian-banking-sql-analytics/
├── data/
│   ├── raw/                         # Synthetic CSV source files
│   └── data_dictionary/             # Table inventory and field dictionary
├── docs/
│   ├── analyst_role_alignment.md
│   ├── business_requirements.md
│   ├── data_dictionary.md
│   ├── erd.md
│   ├── github_presentation_guide.md
│   ├── portfolio_storyboard.md
│   ├── refinement_notes.md
│   ├── sql_concepts_coverage.md
│   └── sql_topic_roadmap_beginner_to_advanced.md
├── sql/
│   ├── 00_setup.sql
│   ├── 01_create_tables.sql
│   ├── 02_load_csv_postgres.sql
│   ├── 03_constraints_indexes.sql
│   ├── 04_data_quality_tests.sql
│   ├── 05_business_views.sql
│   ├── 06_materialized_views.sql
│   ├── 07_functions_procedures.sql
│   ├── 08_security_roles.sql
│   ├── 09_performance_tuning_examples.sql
│   ├── 10_analyst_case_studies.sql
│   ├── 11_deduplication_examples.sql
│   ├── 12_scd_type2_customer_risk_history.sql
│   ├── 13_transaction_control_examples.sql
│   ├── 14_advanced_sql_patterns.sql
│   ├── run_all.sql
│   └── run_advanced.sql
├── answers/                         # Solved analyst SQL questions
├── tests/                           # Data quality and reconciliation checks
├── scripts/                         # Optional validation helpers
├── reports/                         # Sample outputs and executive summary
├── docker-compose.yml
├── Makefile
├── .gitattributes
├── .gitignore
└── README.md
```

---

## How to run locally with Docker + PostgreSQL

The project uses PostgreSQL in Docker. The default host port is `5433` to avoid conflicts with any local PostgreSQL instance already using `5432`.

### 1. Start PostgreSQL

```bash
docker compose up -d
make wait-db
```

### 2. Build the database, load CSVs, create marts, and run checks

```bash
make all
```

`make all` starts Docker and runs `sql/run_all.sql`, which builds the main warehouse, creates the reporting layer, runs analyst case studies, executes performance examples, and runs reconciliation plus assertion-style validation checks.

For a completely clean rebuild from scratch:

```bash
make rebuild
```

### 3. Run only validation checks

```bash
make tests
```

### 4. Run only the analyst case studies

```bash
make cases
```

### 5. Run optional advanced SQL examples

These examples are orchestrated by `sql/run_advanced.sql` and demonstrate deduplication, SCD Type 2 history handling, transaction control, recursive CTEs, pivots/unpivots, lateral joins, arrays, JSONB output, and statistical summaries. The SCD and transaction examples intentionally roll back their changes so the sample dataset remains unchanged.

```bash
make advanced
```

### 6. Connect manually

```bash
docker compose exec postgres psql -U banking_admin -d canadian_banking
```

DBeaver / pgAdmin connection details:

```text
Host: localhost
Port: 5433
Database: canadian_banking
Username: banking_admin
Password: banking_admin_password
Schema: banking
```

---

## SQL skills demonstrated

| Level | Concepts demonstrated |
|---|---|
| Beginner SQL | `SELECT`, `FROM`, `WHERE`, aliases, sorting, limiting, `DISTINCT`, null handling, basic functions |
| Core analyst SQL | Joins, aggregations, `GROUP BY`, `HAVING`, `CASE WHEN`, date calculations, conditional aggregation |
| Intermediate SQL | CTEs, subqueries, set operators, data cleaning, deduplication, reusable views, business KPI logic |
| Advanced SQL | Window functions, `LAG`, `LEAD`, `ROW_NUMBER`, `RANK`, `NTILE`, rolling averages, percentiles, recursive CTEs, lateral joins |
| Financial SQL | Deposit balances, interest income, fees, loan payments, delinquency, card utilization, fraud loss, campaign ROI proxy |
| Data engineering SQL | Typed schemas, CSV loading, primary keys, foreign keys, indexes, materialized views, refresh procedures, SCD Type 2 pattern |
| Data quality | Duplicate checks, orphan-key checks, invalid date checks, numeric-range checks, SLA/date logic checks, reconciliation assertions |
| Performance | Composite indexes, covering indexes, materialized views, `EXPLAIN ANALYZE`, partitioning examples, sargable filter patterns |
| Governance | Read-only roles, analyst roles, grants, revokes, synthetic-data disclaimer, data dictionary, reproducible Docker setup |

For the full beginner-to-advanced SQL topic checklist, review `docs/sql_topic_roadmap_beginner_to_advanced.md`.

---

## Featured business outputs

- Monthly institution KPI view for deposit balance, interest income, fees, and product-family mix.
- Branch target-attainment view comparing actual balances, originations, new accounts, and SLA performance against monthly targets.
- Customer 360 view combining accounts, balances, products, current risk segment, card utilization, and service volume.
- Loan delinquency analytics with customer risk and branch/province context.
- Fraud operations view measuring confirmed fraud, estimated loss, false-positive pressure, severity mix, and resolution status.
- Campaign performance view measuring opens, clicks, conversions, estimated revenue, budget allocation, and ROI proxy.
- Service SLA view measuring breach rates by request type, priority, channel, branch, and institution.

---

## Best files for recruiters to review first

1. `README.md` — project story, business value, and setup.
2. `docs/sql_topic_roadmap_beginner_to_advanced.md` — full beginner-to-advanced SQL roadmap and coverage matrix.
3. `docs/sql_concepts_coverage.md` — recruiter-friendly proof of SQL breadth.
4. `sql/10_analyst_case_studies.sql` — end-to-end business questions.
5. `sql/05_business_views.sql` — reusable analytics layer.
6. `sql/run_all.sql` — reproducible main build orchestration.
7. `sql/04_data_quality_tests.sql` — production-style data validation.
8. `sql/11_deduplication_examples.sql` — duplicate detection and safe cleanup patterns.
9. `sql/12_scd_type2_customer_risk_history.sql` — SCD Type 2 history handling.
10. `sql/run_advanced.sql` — optional advanced SQL orchestration.
11. `reports/executive_insights.md` — example insight communication.

---

## Suggested GitHub description

```text
SQL portfolio project using PostgreSQL and synthetic Canadian banking data to analyze Big 5 bank performance, customer risk, fraud alerts, branch targets, campaigns, loans, cards, service SLAs, and data quality with beginner-to-advanced SQL, CTEs, window functions, SCD Type 2, transactions, views, materialized views, procedures, indexing, security, and Docker.
```

## Suggested topics

```text
sql postgresql banking finance-analytics data-analytics business-intelligence risk-analytics fraud-analytics portfolio-project canada powerbi-ready data-quality star-schema window-functions cte scd-type-2 query-optimization docker
```

---

## Portfolio positioning

This repository is suitable for applications to roles such as:

- Data Analyst
- BI Analyst
- Financial Data Analyst
- Risk Analyst
- Reporting Analyst
- Operations Analyst
- Banking Analyst
- Analytics Engineer Intern / Junior Analytics Engineer

The project is built to show that I can work with realistic financial data, write maintainable SQL, document business logic, validate data quality, and communicate insights in a way that business stakeholders can understand.
