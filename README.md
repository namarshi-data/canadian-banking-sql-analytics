# Canadian Big 5 Banking SQL Analytics

**PostgreSQL portfolio project using synthetic Canadian banking data to analyze customer risk, fraud alerts, branch performance, loans, cards, campaigns, service SLAs, and data quality with advanced SQL.**

## Recruiter Summary

This is a recruiter-facing SQL portfolio project built with PostgreSQL, Docker, and synthetic Canadian banking data. It demonstrates beginner-to-advanced SQL through banking analytics use cases across customer risk, fraud alerts, loans, cards, branch targets, campaigns, service SLAs, and data-quality validation.

The project is designed to show more than basic querying. It includes star-schema modelling, CSV loading, referential integrity, reconciliation checks, reusable business views, materialized views, stored procedures, SCD Type 2 logic, transaction control, indexing, query optimization, security roles, and deployment-ready local execution.

> Dataset status: **synthetic / portfolio-safe / no real customers / no confidential bank data**.

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

## Best files to review first

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
