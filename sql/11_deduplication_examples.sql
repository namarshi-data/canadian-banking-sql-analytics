\echo 'Running deduplication review examples...'

SET search_path TO banking, mart, audit, public;

-- Purpose
-- -------
-- These queries demonstrate professional duplicate detection and safe deduplication patterns.
-- They are intentionally review-first: they identify duplicate candidates without deleting data.

-- 1. Duplicate transaction reference check.
-- A production transaction feed should not contain the same transaction_reference more than once.
SELECT
    transaction_reference,
    COUNT(*) AS duplicate_count,
    MIN(transaction_date) AS first_seen_date,
    MAX(transaction_date) AS last_seen_date,
    SUM(amount) AS total_duplicate_amount
FROM banking.fact_transactions
GROUP BY transaction_reference
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, total_duplicate_amount DESC
LIMIT 50;

-- 2. Duplicate customer business-key check.
-- customer_number is the stable business identifier used outside the database.
SELECT
    customer_number,
    COUNT(*) AS duplicate_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM banking.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, customer_number;

-- 3. Duplicate account-customer ownership relationship check.
-- A customer should not have the same ownership role recorded twice for the same account.
SELECT
    account_id,
    customer_id,
    ownership_role,
    COUNT(*) AS duplicate_count
FROM banking.bridge_account_customers
GROUP BY account_id, customer_id, ownership_role
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, account_id, customer_id;

-- 4. Latest-record selection pattern using ROW_NUMBER.
-- This pattern is used frequently in analyst work when source systems send multiple records
-- and the reporting layer should keep the latest version for each business key.
WITH ranked_risk_records AS (
    SELECT
        risk_history_id,
        customer_id,
        credit_score,
        credit_score_band,
        risk_segment,
        effective_start_date,
        effective_end_date,
        is_current,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY is_current DESC, effective_start_date DESC, effective_end_date DESC, risk_history_id DESC
        ) AS recency_rank
    FROM banking.fact_customer_risk_history
)
SELECT
    risk_history_id,
    customer_id,
    credit_score,
    credit_score_band,
    risk_segment,
    effective_start_date,
    effective_end_date,
    is_current
FROM ranked_risk_records
WHERE recency_rank = 1
ORDER BY customer_id
LIMIT 100;

-- 5. Identify customers with more than one current risk record.
-- This is an important SCD Type 2 integrity check.
SELECT
    customer_id,
    COUNT(*) AS current_record_count,
    MIN(effective_start_date) AS earliest_current_start_date,
    MAX(effective_start_date) AS latest_current_start_date
FROM banking.fact_customer_risk_history
WHERE is_current = TRUE
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY current_record_count DESC, customer_id;

-- 6. Safe deduplication template.
-- Keep this commented unless a reviewed duplicate set must be cleaned in a controlled environment.
/*
BEGIN;

WITH duplicate_candidates AS (
    SELECT
        risk_history_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, effective_start_date, effective_end_date
            ORDER BY is_current DESC, risk_history_id DESC
        ) AS rn
    FROM banking.fact_customer_risk_history
), rows_to_remove AS (
    SELECT risk_history_id
    FROM duplicate_candidates
    WHERE rn > 1
)
DELETE FROM banking.fact_customer_risk_history r
USING rows_to_remove d
WHERE r.risk_history_id = d.risk_history_id;

-- Review rowcount and downstream checks before committing.
-- COMMIT;
ROLLBACK;
*/

\echo 'Deduplication review examples complete.'
