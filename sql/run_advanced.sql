\set ON_ERROR_STOP on
\timing on

\echo ''
\echo '============================================================'
\echo ' Canadian Banking SQL Analytics - Advanced SQL Examples'
\echo '============================================================'
\echo 'This script runs optional portfolio examples that demonstrate'
\echo 'advanced SQL concepts beyond the core warehouse build.'
\echo ''
\echo 'Recommended order: run /sql/run_all.sql first, then this file.'
\echo 'These examples are designed to be dataset-safe; scripts that'
\echo 'demonstrate updates use ROLLBACK intentionally.'
\echo ''

\echo 'Advanced 11 - Deduplication examples'
\i /sql/11_deduplication_examples.sql

\echo ''
\echo 'Advanced 12 - SCD Type 2 customer risk history examples'
\i /sql/12_scd_type2_customer_risk_history.sql

\echo ''
\echo 'Advanced 13 - Transaction control examples'
\i /sql/13_transaction_control_examples.sql

\echo ''
\echo 'Advanced 14 - Advanced SQL patterns'
\i /sql/14_advanced_sql_patterns.sql

\echo ''
\echo '============================================================'
\echo ' Advanced SQL examples complete.'
\echo '============================================================'
\echo 'These examples showcase deduplication, SCD Type 2 logic,'
\echo 'transactions, advanced joins, advanced analytics patterns,'
\echo 'and portfolio-ready SQL problem solving.'
\echo '============================================================'
