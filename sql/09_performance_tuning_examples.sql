\echo 'Running performance-tuning examples and refreshing reporting materialized views...'

SET search_path TO banking, mart, audit, public;

-- 1. Explain a monthly KPI query using composite indexes.
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    month_end_date,
    institution_id,
    product_id,
    SUM(ending_balance) AS ending_balance
FROM banking.fact_monthly_account_balances
WHERE month_end_date BETWEEN DATE '2025-01-31' AND DATE '2025-12-31'
GROUP BY month_end_date, institution_id, product_id
ORDER BY month_end_date, institution_id, product_id;

-- 2. Explain customer transaction retrieval using account/date index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_date,
    transaction_type,
    amount,
    channel,
    transaction_status
FROM banking.fact_transactions
WHERE account_id = 100
ORDER BY transaction_date DESC
LIMIT 50;

-- 3. Example partitioning pattern for a future production transaction table.
-- This is documentation SQL, not executed by default.
/*
CREATE TABLE banking.fact_transactions_partitioned (
    LIKE banking.fact_transactions INCLUDING ALL
) PARTITION BY RANGE (transaction_date);

CREATE TABLE banking.fact_transactions_2025_q1 PARTITION OF banking.fact_transactions_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
*/

-- 4. Refresh materialized views after a new monthly load.
CALL audit.refresh_reporting_marts();

\echo 'Performance-tuning examples complete.'
