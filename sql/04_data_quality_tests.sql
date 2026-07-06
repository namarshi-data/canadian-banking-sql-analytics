\echo 'Running data-quality checks. Non-zero exception_count values should be reviewed with the severity and business_rule columns.'

SET search_path TO banking, public;

WITH checks AS (
    SELECT
        'customers_missing_postal_code' AS check_name,
        'Review' AS severity,
        'Customer addresses should be complete enough for geography and branch-market reporting.' AS business_rule,
        COUNT(*) AS exception_count
    FROM banking.dim_customers
    WHERE postal_code IS NULL

    UNION ALL
    SELECT
        'accounts_closed_before_open',
        'Critical',
        'Closed accounts cannot have a close_date before open_date.',
        COUNT(*)
    FROM banking.fact_accounts
    WHERE close_date IS NOT NULL AND close_date < open_date

    UNION ALL
    SELECT
        'loans_closed_before_origination',
        'Critical',
        'Closed loans cannot have a close_date before origination_date.',
        COUNT(*)
    FROM banking.fact_loans
    WHERE close_date IS NOT NULL AND close_date < origination_date

    UNION ALL
    SELECT
        'transactions_missing_date_key',
        'Critical',
        'Every transaction date_key should resolve to dim_date for time-series reporting.',
        COUNT(*)
    FROM banking.fact_transactions t
    LEFT JOIN banking.dim_date d ON d.date_key = t.date_key
    WHERE d.date_key IS NULL

    UNION ALL
    SELECT
        'balances_missing_date_key',
        'Critical',
        'Every monthly balance date_key should resolve to dim_date for period-end reporting.',
        COUNT(*)
    FROM banking.fact_monthly_account_balances b
    LEFT JOIN banking.dim_date d ON d.date_key = b.date_key
    WHERE d.date_key IS NULL

    UNION ALL
    SELECT
        'orphan_account_customer_id',
        'Critical',
        'Account-level customer_id values should resolve to dim_customers.',
        COUNT(*)
    FROM banking.fact_accounts a
    LEFT JOIN banking.dim_customers c ON c.customer_id = a.customer_id
    WHERE c.customer_id IS NULL

    UNION ALL
    SELECT
        'orphan_campaign_contact_customer_id',
        'Critical',
        'Non-null campaign contact customer_id values should resolve to dim_customers; null customer_id is allowed for prospects or anonymous leads.',
        COUNT(*)
    FROM banking.fact_campaign_contacts cc
    LEFT JOIN banking.dim_customers c ON c.customer_id = cc.customer_id
    WHERE cc.customer_id IS NOT NULL
      AND c.customer_id IS NULL

    UNION ALL
    SELECT
        'card_utilization_above_100_pct',
        'Review',
        'Utilization above 100% can occur with over-limit balances but should be monitored.',
        COUNT(*)
    FROM banking.fact_card_statements
    WHERE utilization_rate > 1.00

    UNION ALL
    SELECT
        'loan_payments_late_more_than_30_days',
        'Review',
        'Payments more than 30 days late indicate delinquency risk for portfolio monitoring.',
        COUNT(*)
    FROM banking.fact_loan_payments
    WHERE days_late > 30

    UNION ALL
    SELECT
        'service_sla_breach_flag_mismatch',
        'Critical',
        'SLA breach flag should match the comparison between resolution_hours and sla_target_hours.',
        COUNT(*)
    FROM banking.fact_service_requests
    WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours)

    UNION ALL
    SELECT
        'campaign_click_without_open',
        'Review',
        'A click without an open can be caused by tracking limitations and should be reviewed.',
        COUNT(*)
    FROM banking.fact_campaign_contacts
    WHERE clicked_flag = TRUE AND opened_flag = FALSE

    UNION ALL
    SELECT
        'campaign_conversion_without_click',
        'Review',
        'A conversion without a click may represent assisted/offline conversion and should be reviewed.',
        COUNT(*)
    FROM banking.fact_campaign_contacts
    WHERE converted_flag = TRUE AND clicked_flag = FALSE

    UNION ALL
    SELECT
        'campaign_contacts_without_customer_id',
        'Monitor',
        'Null customer_id is allowed for prospect, anonymous, or pre-acquisition marketing outreach and is retained for campaign-level analysis.',
        COUNT(*)
    FROM banking.fact_campaign_contacts
    WHERE customer_id IS NULL

    UNION ALL
    SELECT
        'risk_history_without_credit_score',
        'Monitor',
        'Null credit_score is allowed for new-to-credit, thin-file, or unscoreable customers and is retained under No Score segmentation.',
        COUNT(*)
    FROM banking.fact_customer_risk_history
    WHERE credit_score IS NULL

    UNION ALL
    SELECT
        'risk_history_invalid_credit_score_range',
        'Critical',
        'Populated credit_score values should remain in the expected 300-900 synthetic bureau-score range.',
        COUNT(*)
    FROM banking.fact_customer_risk_history
    WHERE credit_score IS NOT NULL
      AND (credit_score < 300 OR credit_score > 900)

    UNION ALL
    SELECT
        'risk_history_no_score_band_mismatch',
        'Critical',
        'Rows with a null credit_score should be classified as No Score for transparent risk segmentation.',
        COUNT(*)
    FROM banking.fact_customer_risk_history
    WHERE credit_score IS NULL
      AND credit_score_band IS DISTINCT FROM 'No Score'
)
SELECT
    check_name,
    severity,
    business_rule,
    exception_count
FROM checks
ORDER BY
    CASE severity
        WHEN 'Critical' THEN 1
        WHEN 'Review' THEN 2
        WHEN 'Monitor' THEN 3
        ELSE 4
    END,
    exception_count DESC,
    check_name;

-- Business-valid null profile: campaign contacts can include prospects or anonymous leads.
SELECT
    COUNT(*) AS total_campaign_contacts,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS prospect_or_unknown_contacts,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE customer_id IS NULL) / NULLIF(COUNT(*), 0),
        2
    ) AS pct_without_customer_id
FROM banking.fact_campaign_contacts;

-- Business-valid null profile: customers can be new-to-credit, thin-file, or not scoreable.
SELECT
    COUNT(*) AS total_risk_records,
    COUNT(*) FILTER (WHERE credit_score IS NULL) AS no_score_records,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE credit_score IS NULL) / NULLIF(COUNT(*), 0),
        2
    ) AS pct_no_score
FROM banking.fact_customer_risk_history;

-- Detailed exception extract: transactions outside the date dimension.
SELECT
    t.transaction_id,
    t.transaction_date,
    t.date_key,
    t.institution_id,
    t.account_id,
    t.amount,
    t.transaction_status
FROM banking.fact_transactions t
LEFT JOIN banking.dim_date d ON d.date_key = t.date_key
WHERE d.date_key IS NULL
ORDER BY t.transaction_date;

-- Detailed exception extract: SLA breach flags not aligned to the business rule.
SELECT
    service_request_id,
    service_request_number,
    sla_target_hours,
    resolution_hours,
    sla_breached_flag,
    (resolution_hours > sla_target_hours) AS expected_sla_breached_flag
FROM banking.fact_service_requests
WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours)
ORDER BY service_request_id;
