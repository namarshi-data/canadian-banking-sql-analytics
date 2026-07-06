\echo 'Demonstrating transaction control, rollback, and savepoints...'

SET search_path TO banking, mart, audit, public;

-- Purpose
-- -------
-- Analysts often need to correct data safely. This script demonstrates BEGIN, COMMIT,
-- ROLLBACK, and SAVEPOINT patterns without permanently changing the portfolio dataset.

-- Example 1: Review-and-rollback pattern for a calculated SLA flag correction.
BEGIN;

SELECT
    COUNT(*) AS rows_that_would_be_corrected
FROM banking.fact_service_requests
WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours);

UPDATE banking.fact_service_requests
SET sla_breached_flag = (resolution_hours > sla_target_hours)
WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours);

-- Validate the correction before deciding whether to commit.
SELECT
    COUNT(*) AS remaining_mismatched_sla_flags
FROM banking.fact_service_requests
WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours);

-- Demonstration only: keep sample data unchanged.
ROLLBACK;

-- Example 2: Savepoint pattern for multi-step data maintenance.
BEGIN;

SAVEPOINT before_status_review;

-- This update is intentionally no-op for the clean dataset, but it demonstrates the pattern.
UPDATE banking.fact_transactions
SET transaction_status = 'Completed'
WHERE transaction_status = 'completed';

-- Roll back only the work after the savepoint, not the whole transaction.
ROLLBACK TO SAVEPOINT before_status_review;

-- Additional checks can still run inside the same transaction.
SELECT
    transaction_status,
    COUNT(*) AS transaction_count
FROM banking.fact_transactions
GROUP BY transaction_status
ORDER BY transaction_count DESC;

-- Demonstration only.
ROLLBACK;

-- Production pattern, when validation passes:
/*
BEGIN;
UPDATE banking.fact_service_requests
SET sla_breached_flag = (resolution_hours > sla_target_hours)
WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours);
COMMIT;
*/

\echo 'Transaction-control examples complete.'
