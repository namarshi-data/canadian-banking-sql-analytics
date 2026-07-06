\echo 'Running assertion-style data quality checks...'

\set ON_ERROR_STOP on

SET search_path TO banking, public;

DROP TABLE IF EXISTS pg_temp.data_quality_assertion_results;

-- This file is intentionally stricter than sql/04_data_quality_tests.sql.
-- Business-valid monitoring items are allowed, but core integrity assertions must pass.
CREATE TEMP TABLE data_quality_assertion_results AS
WITH assertions AS (
    SELECT 'primary_customer_keys_unique' AS assertion_name,
           CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS' ELSE 'FAIL' END AS status,
           COUNT(*) - COUNT(DISTINCT customer_id) AS exception_count
    FROM dim_customers

    UNION ALL
    SELECT 'account_numbers_unique',
           CASE WHEN COUNT(*) = COUNT(DISTINCT account_number) THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*) - COUNT(DISTINCT account_number)
    FROM fact_accounts

    UNION ALL
    SELECT 'transaction_references_unique',
           CASE WHEN COUNT(*) = COUNT(DISTINCT transaction_reference) THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*) - COUNT(DISTINCT transaction_reference)
    FROM fact_transactions

    UNION ALL
    SELECT 'date_dimension_covers_balances',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM fact_monthly_account_balances b
    LEFT JOIN dim_date d ON d.date_key = b.date_key
    WHERE d.date_key IS NULL

    UNION ALL
    SELECT 'date_dimension_covers_transactions',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM fact_transactions t
    LEFT JOIN dim_date d ON d.date_key = t.date_key
    WHERE d.date_key IS NULL

    UNION ALL
    SELECT 'service_sla_breach_flag_aligned',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM fact_service_requests
    WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours)

    UNION ALL
    SELECT 'campaign_non_null_customer_ids_are_valid',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM fact_campaign_contacts cc
    LEFT JOIN dim_customers c ON c.customer_id = cc.customer_id
    WHERE cc.customer_id IS NOT NULL
      AND c.customer_id IS NULL

    UNION ALL
    SELECT 'risk_scores_valid_when_present',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM fact_customer_risk_history
    WHERE credit_score IS NOT NULL
      AND (credit_score < 300 OR credit_score > 900)

    UNION ALL
    SELECT 'no_score_records_are_labeled',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM fact_customer_risk_history
    WHERE credit_score IS NULL
      AND credit_score_band IS DISTINCT FROM 'No Score'
)
SELECT
    assertion_name,
    status,
    exception_count
FROM assertions;

SELECT
    assertion_name,
    status,
    exception_count
FROM data_quality_assertion_results
ORDER BY status, assertion_name;

DO $$
DECLARE
    failed_assertion_count integer;
BEGIN
    SELECT COUNT(*)
    INTO failed_assertion_count
    FROM data_quality_assertion_results
    WHERE status = 'FAIL';

    IF failed_assertion_count > 0 THEN
        RAISE EXCEPTION 'Data quality assertions failed: % assertion(s) returned FAIL.', failed_assertion_count;
    END IF;
END $$;

\echo 'Data quality assertions completed successfully.'
