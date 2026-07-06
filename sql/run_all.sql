\set ON_ERROR_STOP on
\timing on

\echo ''
\echo '============================================================'
\echo ' Canadian Banking SQL Analytics - Main Build'
\echo '============================================================'
\echo 'This script builds the core PostgreSQL analytics warehouse,'
\echo 'creates the reporting layer, runs performance examples, and'
\echo 'executes reconciliation plus assertion-style quality checks.'
\echo 'Advanced/demo-only SQL examples are intentionally separated'
\echo 'into /sql/run_advanced.sql so the main build stays clean,'
\echo 'repeatable, and recruiter-friendly.'
\echo ''

\echo 'Step 00 - Setup database schemas and environment'
\i /sql/00_setup.sql

\echo ''
\echo 'Step 01 - Create tables'
\i /sql/01_create_tables.sql

\echo ''
\echo 'Step 02 - Load CSV data'
\i /sql/02_load_csv_postgres.sql

\echo ''
\echo 'Step 03 - Apply constraints and indexes'
\i /sql/03_constraints_indexes.sql

\echo ''
\echo 'Step 04 - Create business/reporting views'
\i /sql/05_business_views.sql

\echo ''
\echo 'Step 05 - Create materialized views'
\i /sql/06_materialized_views.sql

\echo ''
\echo 'Step 06 - Create functions and stored procedures'
\i /sql/07_functions_procedures.sql

\echo ''
\echo 'Step 07 - Apply security roles and permissions'
\i /sql/08_security_roles.sql

\echo ''
\echo 'Step 08 - Run analyst case studies'
\i /sql/10_analyst_case_studies.sql

\echo ''
\echo 'Step 09 - Run query optimization / performance examples'
\i /sql/09_performance_tuning_examples.sql

\echo ''
\echo 'Step 10 - Run data-quality profiling checks'
\i /sql/04_data_quality_tests.sql

\echo ''
\echo 'Step 11 - Run source-to-target reconciliation checks'
\i /tests/reconciliation_checks.sql

\echo ''
\echo 'Step 12 - Run assertion-style data-quality checks'
\i /tests/data_quality_assertions.sql

\echo ''
\echo '============================================================'
\echo ' Main build complete.'
\echo '============================================================'
\echo 'Optional advanced SQL examples are available in:'
\echo '  /sql/run_advanced.sql'
\echo ''
\echo 'Run them with:'
\echo '  make advanced'
\echo 'or manually inside psql with:'
\echo '  \i /sql/run_advanced.sql'
\echo '============================================================'
