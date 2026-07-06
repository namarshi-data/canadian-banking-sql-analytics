# SQL Topic Roadmap: Beginner to Intermediate to Advanced

This roadmap is included to make the portfolio easy for recruiters, hiring managers, and interviewers to review. It shows the SQL learning path from core querying to production-style analytics engineering, and it maps the most job-relevant skills back to this Canadian banking SQL project.

> Project positioning: this repository is not meant to show every SQL keyword in isolation. It demonstrates job-relevant SQL through banking analytics use cases: data modeling, loading, quality checks, reconciliation, KPI reporting, financial calculations, window functions, performance tuning, security, and dashboard-ready reporting views.

---

## 1. Beginner SQL Topics

### 1.1 SQL fundamentals

- What SQL is and why analysts use it
- Relational databases
- Schemas, tables, rows, and columns
- Primary keys
- Foreign keys
- Entity relationships
- Business keys versus technical keys
- Data types
- SQL dialects: PostgreSQL, MySQL, SQL Server, Oracle, SQLite
- SQL comments and formatting
- Query readability

**Project evidence:** `sql/00_setup.sql`, `sql/01_create_tables.sql`, `docs/erd.md`, `docs/data_dictionary.md`.

### 1.2 Basic data retrieval

- `SELECT`
- `FROM`
- Selecting specific columns
- Selecting all columns using `*`
- Column aliases with `AS`
- Basic calculated columns
- Arithmetic expressions
- String concatenation
- `DISTINCT`

**Project evidence:** `answers/01_core_sql_questions.sql`, `sql/10_analyst_case_studies.sql`.

### 1.3 Filtering data

- `WHERE`
- `=`, `<>`, `!=`, `>`, `<`, `>=`, `<=`
- `AND`, `OR`, `NOT`
- `BETWEEN`
- `IN`
- `LIKE`
- `ILIKE`
- `%` and `_` wildcards
- `IS NULL`
- `IS NOT NULL`
- Filtering active, closed, pending, failed, or exceptional records

**Project evidence:** used throughout `sql/04_data_quality_tests.sql`, `sql/05_business_views.sql`, and `sql/10_analyst_case_studies.sql`.

### 1.4 Sorting and limiting

- `ORDER BY`
- Ascending and descending order
- Sorting by multiple columns
- `LIMIT`
- `OFFSET`
- `FETCH FIRST`
- SQL Server `TOP`

**Project evidence:** case-study queries and sample analyst answers.

### 1.5 Basic aggregation

- `COUNT`
- `SUM`
- `AVG`
- `MIN`
- `MAX`
- `GROUP BY`
- `HAVING`
- Difference between `WHERE` and `HAVING`
- Grouping by business dimensions such as institution, province, product, customer segment, month, and branch

**Project evidence:** `sql/05_business_views.sql`, `sql/10_analyst_case_studies.sql`, `reports/executive_insights.md`.

### 1.6 Basic SQL functions

- Text functions: `LOWER`, `UPPER`, `TRIM`, `LTRIM`, `RTRIM`, `LENGTH`, `SUBSTRING`, `REPLACE`, `CONCAT`
- Numeric functions: `ROUND`, `CEIL`, `FLOOR`, `ABS`
- Date functions: `CURRENT_DATE`, `CURRENT_TIMESTAMP`, `DATE_PART`, `EXTRACT`, `DATE_TRUNC`, `DATEADD`, `DATEDIFF`
- Null-handling functions: `COALESCE`, `NULLIF`

**Project evidence:** load standardization, KPI calculations, risk tiering, date-based marts.

### 1.7 Basic joins

- `INNER JOIN`
- `LEFT JOIN`
- `RIGHT JOIN`
- `FULL OUTER JOIN`
- Table aliases
- Join keys
- One-to-one relationships
- One-to-many relationships
- Many-to-many relationships
- Bridge tables

**Project evidence:** banking star schema joins across institutions, branches, products, customers, accounts, balances, campaigns, fraud alerts, and service requests.

### 1.8 Basic data modification

- `INSERT`
- `UPDATE`
- `DELETE`
- `TRUNCATE`
- Difference between `DELETE`, `TRUNCATE`, and `DROP`
- Safe update practices

**Project evidence:** `sql/02_load_csv_postgres.sql`, `sql/12_scd_type2_customer_risk_history.sql`, `sql/13_transaction_control_examples.sql`.

### 1.9 Table creation and data types

- `CREATE TABLE`
- `DROP TABLE`
- `ALTER TABLE`
- `CREATE DATABASE`
- `INT`, `BIGINT`, `NUMERIC`, `DECIMAL`, `VARCHAR`, `TEXT`, `DATE`, `TIMESTAMP`, `BOOLEAN`
- Nullable versus required fields

**Project evidence:** `sql/01_create_tables.sql`.

---

## 2. Intermediate SQL Topics

### 2.1 Advanced filtering

- Complex `WHERE` logic
- Nested conditions
- Case-sensitive and case-insensitive filtering
- Date filters
- Rolling period filters
- Missing-value filters
- Duplicate filters
- Exception filters
- Business rule filters

**Project evidence:** data-quality tests, reconciliation checks, fraud analytics, SLA analytics.

### 2.2 Conditional logic

- `CASE WHEN`
- Nested `CASE`
- Business categories
- Risk tiers
- SLA flags
- Delinquency buckets
- Customer segments
- Status classifications
- Conditional aggregation

**Project evidence:** `sql/05_business_views.sql`, `sql/07_functions_procedures.sql`, `sql/10_analyst_case_studies.sql`.

### 2.3 Intermediate aggregations

- Aggregating by multiple dimensions
- Month, quarter, and year analysis
- Conditional `COUNT`
- Conditional `SUM`
- Percentage and ratio calculations
- Revenue per customer
- Average balance
- Conversion rate
- Fraud confirmation rate
- SLA breach rate
- Portfolio concentration

**Project evidence:** mart views, executive reports, analyst case studies.

### 2.4 Joins in depth

- Multi-table joins
- Self joins
- Cross joins
- Semi joins
- Anti joins
- Non-equi joins
- Joining on multiple columns
- Joining to date ranges
- Join cardinality analysis
- Join debugging
- Finding unmatched records
- Handling duplicate rows after joins

**Project evidence:** `sql/04_data_quality_tests.sql`, `sql/05_business_views.sql`, `sql/11_deduplication_examples.sql`.

### 2.5 Subqueries

- Subqueries in `WHERE`
- Subqueries in `FROM`
- Subqueries in `SELECT`
- Correlated subqueries
- Non-correlated subqueries
- `EXISTS`
- `NOT EXISTS`
- `IN` versus `EXISTS`
- Scalar subqueries
- Derived tables

**Project evidence:** data-quality checks, reusable functions, case studies.

### 2.6 Common Table Expressions

- `WITH` clauses
- Single CTEs
- Multiple CTEs
- Chained CTEs
- CTEs for readability
- CTEs for debugging
- CTEs for business logic layering
- Recursive CTE basics

**Project evidence:** `sql/10_analyst_case_studies.sql`, `sql/11_deduplication_examples.sql`, `sql/14_advanced_sql_patterns.sql`.

### 2.7 Set operators

- `UNION`
- `UNION ALL`
- `INTERSECT`
- `EXCEPT`
- Combining results from multiple checks
- Finding records in one set but not another

**Project evidence:** `sql/04_data_quality_tests.sql`, `tests/reconciliation_checks.sql`, `tests/data_quality_assertions.sql`.

### 2.8 Data cleaning with SQL

- Handling nulls
- `COALESCE`
- `NULLIF`
- Text standardization
- Trimming spaces
- Consistent casing
- Invalid date handling
- Negative value checks
- Business-valid exception handling
- Creating clean reporting fields

**Project evidence:** `sql/02_load_csv_postgres.sql`, `sql/04_data_quality_tests.sql`.

### 2.9 Deduplication

- Finding duplicates
- Duplicate business keys
- Duplicate transaction references
- Duplicate customer records
- Deduplication with `ROW_NUMBER`
- Keeping the latest record
- Keeping the first record
- Reviewing duplicate impact before deletion

**Project evidence:** `sql/11_deduplication_examples.sql`, `tests/data_quality_assertions.sql`.

### 2.10 Date and time analysis

- Extracting year, quarter, month, week, and day
- Month-over-month analysis
- Year-over-year analysis
- Rolling 7-day, 30-day, and 90-day periods
- Fiscal period logic
- Calendar tables
- Weekend versus weekday analysis
- Aging buckets
- Customer tenure
- Loan delinquency days
- Payment delay analysis

**Project evidence:** `dim_date`, monthly balance facts, loan payments, service requests, campaign contacts.

### 2.11 Views

- `CREATE VIEW`
- `CREATE OR REPLACE VIEW`
- Reporting views
- Business logic views
- Layered views
- Dashboard-ready semantic layers
- View maintenance

**Project evidence:** `sql/05_business_views.sql`.

### 2.12 Index basics

- What indexes do
- Single-column indexes
- Composite indexes
- Indexes on join keys
- Indexes on filter columns
- Indexes on date columns
- When indexes help
- When indexes hurt

**Project evidence:** `sql/03_constraints_indexes.sql`, `sql/09_performance_tuning_examples.sql`.

### 2.13 Constraints

- `PRIMARY KEY`
- `FOREIGN KEY`
- `UNIQUE`
- `NOT NULL`
- `CHECK`
- `DEFAULT`
- Referential integrity
- Cascading update/delete concepts
- Real-world imperfect data handling using `NOT VALID` constraints

**Project evidence:** `sql/03_constraints_indexes.sql`.

### 2.14 Database design basics

- Normalization
- 1NF, 2NF, 3NF
- Fact tables
- Dimension tables
- Star schema basics
- Snowflake schema basics
- Entity relationship diagrams
- Grain definition
- Business keys versus surrogate keys

**Project evidence:** `docs/erd.md`, `docs/data_dictionary.md`, `sql/01_create_tables.sql`.

---

## 3. Advanced SQL Topics

### 3.1 Window functions

- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `NTILE`
- `SUM() OVER`
- `AVG() OVER`
- `COUNT() OVER`
- `MIN() OVER`
- `MAX() OVER`
- `LAG`
- `LEAD`
- `FIRST_VALUE`
- `LAST_VALUE`
- Window frames using `ROWS BETWEEN`
- Running totals
- Moving averages
- Contribution to total
- Prior-period comparison
- Top-N per group

**Project evidence:** `answers/02_advanced_sql_window_functions.sql`, `sql/10_analyst_case_studies.sql`, `sql/11_deduplication_examples.sql`.

### 3.2 Advanced analytics SQL

- Cohort analysis
- Retention analysis
- Vintage analysis
- Funnel analysis
- RFM analysis
- Churn indicators
- Rolling time-series analysis
- Seasonality analysis
- Outlier detection
- Percentiles
- Median
- Standard deviation
- Variance
- Z-scores
- Correlation concepts

**Project evidence:** `sql/10_analyst_case_studies.sql`, `sql/14_advanced_sql_patterns.sql`, `mart.v_service_sla`.

### 3.3 Financial analytics SQL

- Revenue analysis
- Expense analysis
- Gross margin and net margin concepts
- Interest income
- Fee income
- Deposit balances
- Loan originations
- Loan payment performance
- Delinquency analysis
- Credit utilization
- AR/AP aging logic concepts
- Working capital concepts
- Risk exposure analysis
- Portfolio concentration
- Branch performance
- Product profitability

**Project evidence:** banking facts, KPI marts, loan and card analytics, branch targets, fraud loss analysis.

### 3.4 Banking analytics SQL

- Customer deposits
- Loan portfolio analytics
- Account balances
- Transaction monitoring
- Cross-sell analysis
- Customer 360
- Branch KPI analytics
- Product penetration
- Dormant accounts
- Fraud indicators
- Card utilization
- Payment behavior
- Loan delinquency
- Service SLA monitoring
- Campaign conversion

**Project evidence:** full repository business scope.

### 3.5 Complex CTE pipelines

- Multi-step transformations
- Staging CTEs
- Business logic layering
- KPI calculation layers
- Reconciliation logic
- Audit-ready SQL
- Debuggable analytics queries

**Project evidence:** `sql/10_analyst_case_studies.sql`, `tests/reconciliation_checks.sql`.

### 3.6 Recursive CTEs

- Hierarchies
- Organization charts
- Category trees
- Account rollups
- Parent-child relationships
- Calendar/date generation

**Project evidence:** `sql/14_advanced_sql_patterns.sql` includes a recursive calendar example.

### 3.7 Advanced subqueries and lateral logic

- Correlated subqueries
- `LATERAL` joins
- `CROSS APPLY` / `OUTER APPLY` concepts in SQL Server
- Top-N related records per row
- Rewriting subqueries as joins for performance

**Project evidence:** `sql/14_advanced_sql_patterns.sql`.

### 3.8 Pivoting and unpivoting

- `PIVOT`
- `UNPIVOT`
- Conditional aggregation pivot
- Wide-to-long transformation
- Long-to-wide transformation
- Crosstab-style reports

**Project evidence:** `sql/14_advanced_sql_patterns.sql`.

### 3.9 Dynamic SQL

- Building SQL strings
- Dynamic reports
- Dynamic pivots
- Parameterized dynamic SQL
- SQL injection risk
- Safe dynamic SQL guidelines

**Project status:** documented as an advanced production topic; not executed by default because this project prioritizes analyst-safe static SQL.

### 3.10 Temporary tables

- Local temporary tables
- Staging tables
- Temp tables versus CTEs
- Temp table indexing
- Safe experimentation
- Transaction-scoped work tables

**Project evidence:** `sql/02_load_csv_postgres.sql`, `sql/12_scd_type2_customer_risk_history.sql`, `sql/13_transaction_control_examples.sql`.

### 3.11 Query execution and optimization

- Logical query processing order
- Execution plans
- Cost-based optimization
- Sequential scan
- Index scan
- Bitmap scan
- Nested loop join
- Hash join
- Merge join
- Predicate pushdown
- Sargability
- Avoiding unnecessary columns
- Avoiding functions on indexed columns
- Optimizing joins
- Optimizing filters
- Optimizing `GROUP BY`
- Optimizing `ORDER BY`
- Optimizing window functions

**Project evidence:** `sql/09_performance_tuning_examples.sql`, index definitions, materialized views.

### 3.12 Advanced indexing

- B-tree indexes
- Hash indexes
- Composite indexes
- Covering indexes
- Partial indexes
- Filtered indexes
- Unique indexes
- Clustered and non-clustered index concepts
- Selectivity
- Cardinality
- Index-only scans
- Index maintenance

**Project evidence:** `sql/03_constraints_indexes.sql`, `sql/09_performance_tuning_examples.sql`.

### 3.13 Partitioning

- Table partitioning
- Range partitioning
- List partitioning
- Hash partitioning
- Date-based partitioning
- Partition pruning
- Partition maintenance
- Archiving old data

**Project evidence:** partitioning pattern in `sql/09_performance_tuning_examples.sql`.

### 3.14 Materialized views

- `CREATE MATERIALIZED VIEW`
- Refreshing materialized views
- Dashboard acceleration
- Performance trade-offs
- Refresh procedures
- Incremental refresh concepts

**Project evidence:** `sql/06_materialized_views.sql`, `sql/07_functions_procedures.sql`.

### 3.15 Advanced database design

- Conceptual model
- Logical model
- Physical model
- OLTP modeling
- OLAP modeling
- Dimensional modeling
- Star schema
- Snowflake schema
- Data marts
- Conformed dimensions
- Degenerate dimensions
- Bridge tables
- Snapshot facts
- Transaction facts
- Accumulating snapshot concepts
- Periodic snapshot facts

**Project evidence:** `sql/01_create_tables.sql`, `docs/erd.md`, monthly balance facts, branch target facts, transaction facts.

### 3.16 Slowly Changing Dimensions

- SCD Type 0
- SCD Type 1
- SCD Type 2
- SCD Type 3
- Effective start date
- Effective end date
- Current flag
- Historical tracking
- Expire-and-insert pattern

**Project evidence:** `fact_customer_risk_history`, `sql/12_scd_type2_customer_risk_history.sql`.

### 3.17 ETL and ELT

- Extract, transform, load
- Extract, load, transform
- Raw layer
- Staging layer
- Clean layer
- Analytics layer
- Full refresh loads
- Incremental load concepts
- Idempotent load design
- Source-to-target validation

**Project evidence:** `sql/02_load_csv_postgres.sql`, `tests/reconciliation_checks.sql`, Docker/Makefile workflow.

### 3.18 Data quality checks

- Row-count validation
- Null checks
- Duplicate checks
- Referential integrity checks
- Range checks
- Format checks
- Outlier checks
- Reconciliation checks
- Control totals
- Source-to-report validation
- Severity classification

**Project evidence:** `sql/04_data_quality_tests.sql`, `tests/data_quality_assertions.sql`, `tests/reconciliation_checks.sql`.

### 3.19 Incremental loading and upserts

- Watermark columns
- Last-updated timestamps
- Change data capture concepts
- `MERGE`
- PostgreSQL `INSERT ... ON CONFLICT`
- MySQL `INSERT ... ON DUPLICATE KEY UPDATE`
- SCD Type 2 merge concepts
- Deduplicated loading

**Project evidence:** `sql/12_scd_type2_customer_risk_history.sql` documents the SCD update/insert pattern.

### 3.20 Stored procedures and functions

- Scalar functions
- Table-valued functions
- Stored procedures
- Variables
- Parameters
- Error handling concepts
- Scheduling procedures
- Refresh procedures

**Project evidence:** `sql/07_functions_procedures.sql`.

### 3.21 Triggers

- Before insert triggers
- After insert triggers
- Update triggers
- Delete triggers
- Audit triggers
- Risks and best practices

**Project status:** documented as an advanced database-engineering topic; not implemented because this portfolio uses transparent batch SQL and explicit audit checks instead of hidden trigger side effects.

### 3.22 Transactions and concurrency

- `BEGIN`
- `COMMIT`
- `ROLLBACK`
- Savepoints
- ACID properties
- Read uncommitted
- Read committed
- Repeatable read
- Serializable
- Dirty reads
- Non-repeatable reads
- Phantom reads
- Row-level locks
- Table-level locks
- Deadlocks
- MVCC

**Project evidence:** `sql/13_transaction_control_examples.sql`.

### 3.23 Security and governance

- User creation
- Role creation
- `GRANT`
- `REVOKE`
- Read-only access
- Analyst access
- Schema-level permissions
- Table-level permissions
- Least privilege
- Data dictionary
- Metadata
- Data lineage
- Auditability
- Synthetic-data disclaimer
- Financial data governance mindset

**Project evidence:** `sql/08_security_roles.sql`, `docs/data_dictionary.md`, `README.md`.

### 3.24 SQL for reporting and BI

- KPI reporting
- Executive summary tables
- Dashboard-ready views
- Power BI-ready fact/dimension structures
- Monthly trend tables
- Drill-through tables
- Exception reports
- Scorecards
- Semantic reporting layer

**Project evidence:** `sql/05_business_views.sql`, `sql/06_materialized_views.sql`, `reports/`.

### 3.25 Modern SQL topics

- JSON and semi-structured data
- `JSONB`
- JSON field extraction
- Arrays
- `UNNEST`
- Full-text search concepts
- Geospatial SQL concepts
- Percentiles and statistical functions
- Advanced analytic summaries

**Project evidence:** `sql/14_advanced_sql_patterns.sql` includes optional advanced pattern examples. JSON/geospatial topics are documented as modern extensions and are not core to the banking CSV dataset.

---

## 4. Job-Showcase SQL Coverage Matrix

| Job-relevant topic | Coverage status | Main project evidence |
|---|---|---|
| Joins | Strong | `sql/05_business_views.sql`, `sql/10_analyst_case_studies.sql` |
| Aggregations | Strong | KPI marts and case studies |
| CTEs | Strong | Analyst case studies and dedup examples |
| Window functions | Strong | Advanced answers, ranking, `LAG`, rolling metrics, deciles |
| `CASE WHEN` logic | Strong | Risk tiers, SLA flags, delinquency buckets |
| Date calculations | Strong | `dim_date`, monthly facts, service and loan aging |
| Data cleaning | Strong | Load standardization and quality checks |
| Deduplication | Strong | `sql/11_deduplication_examples.sql` |
| Subqueries | Strong | Functions, quality checks, case studies |
| Views | Strong | `sql/05_business_views.sql` |
| KPI reporting | Strong | Mart views and executive insights |
| Financial calculations | Strong | Balances, interest, fees, loan payments, utilization, fraud loss |
| Data quality checks | Strong | `sql/04_data_quality_tests.sql`, `tests/` |
| Reconciliation queries | Strong | `tests/reconciliation_checks.sql` |
| Indexing basics | Strong | `sql/03_constraints_indexes.sql` |
| Query optimization | Strong | `sql/09_performance_tuning_examples.sql` |
| Star schema design | Strong | Dimensions, facts, bridge table, marts |
| Fact and dimension tables | Strong | 22-table banking model |
| SCD Type 2 logic | Strong | `fact_customer_risk_history`, `sql/12_scd_type2_customer_risk_history.sql` |
| ETL / ELT pipelines | Strong | `sql/02_load_csv_postgres.sql`, Docker, Makefile |
| Stored procedures | Strong | `audit.refresh_reporting_marts()` |
| Transactions | Strong | `sql/13_transaction_control_examples.sql` |
| Security and permissions | Strong | `sql/08_security_roles.sql` |
| Dashboard-ready reporting views | Strong | `mart` schema views and materialized views |
| Business problem solving with SQL | Strong | Banking case studies and executive report |

---

## 5. Interview Topics This Project Helps Demonstrate

### Beginner interview readiness

- Explain `WHERE` versus `HAVING`
- Explain joins
- Explain primary key versus foreign key
- Explain `DELETE`, `TRUNCATE`, and `DROP`
- Explain aggregation and grouping
- Explain null handling
- Explain basic data types

### Intermediate interview readiness

- Find duplicate records
- Find customers with no related records
- Calculate monthly KPIs
- Calculate conversion rates
- Create business categories with `CASE WHEN`
- Use CTEs to structure complex logic
- Use `UNION ALL` for data-quality reports
- Explain why a query may duplicate rows after a join

### Advanced interview readiness

- Rank branches or customers within each institution
- Calculate rolling averages and period-over-period change
- Build a star schema
- Design a dashboard-ready reporting layer
- Build an SCD Type 2 history pattern
- Reconcile source and target tables
- Review a query plan with `EXPLAIN ANALYZE`
- Add indexes for dashboard/reporting workloads
- Create least-privilege reporting roles
- Use transaction control for safe database changes

---

## 6. How to Present This in a Resume or GitHub README

Recommended resume bullet:

> Built a PostgreSQL banking analytics warehouse using synthetic Canadian financial data, implementing a star schema, ETL loading, data-quality assertions, reconciliation checks, KPI reporting views, materialized views, advanced CTE/window-function case studies, SCD Type 2 history logic, indexing, transaction control, stored procedures, security roles, and Docker-based local deployment.

Recommended GitHub positioning:

> This project demonstrates beginner-to-advanced SQL through a realistic Canadian banking analytics scenario, covering core querying, joins, aggregations, CTEs, window functions, financial KPIs, data quality, reconciliation, performance tuning, star schema design, ETL/ELT, SCD Type 2 logic, security, and dashboard-ready reporting views.
