\echo 'Running reconciliation checks against expected source row counts...'

\set ON_ERROR_STOP on

SET search_path TO banking;

DROP TABLE IF EXISTS reconciliation_results;

CREATE TEMP TABLE reconciliation_results AS
WITH expected_source_counts (
    table_name,
    expected_rows,
    reconciliation_rule,
    business_note
) AS (
    VALUES
        ('bridge_account_customers', 15545::bigint, 'EXACT',   'Bridge table should reconcile exactly to the generated source file.'),
        ('dim_branches', 226::bigint, 'EXACT',                 'Branch dimension should reconcile exactly to the generated source file.'),
        ('dim_campaigns', 6::bigint, 'EXACT',                  'Campaign dimension should reconcile exactly to the generated source file.'),
        ('dim_customers', 7000::bigint, 'EXACT',               'Customer dimension should reconcile exactly to the generated source file.'),

        -- dim_date is an enriched reporting dimension. During load, valid transaction dates
        -- outside the base calendar are added so fact_transactions.date_key always resolves.
        ('dim_date', 1096::bigint, 'MINIMUM',                  'Date dimension may be extended during load to cover valid fact-table dates.'),

        ('dim_geography', 27::bigint, 'EXACT',                 'Geography dimension should reconcile exactly to the generated source file.'),
        ('dim_institutions', 6::bigint, 'EXACT',               'Institution dimension should reconcile exactly to the generated source file.'),
        ('dim_interest_rates', 7::bigint, 'EXACT',             'Interest-rate dimension should reconcile exactly to the generated source file.'),
        ('dim_products', 15::bigint, 'EXACT',                  'Product dimension should reconcile exactly to the generated source file.'),
        ('dim_tax_rates', 14::bigint, 'EXACT',                 'Tax-rate dimension should reconcile exactly to the generated source file.'),
        ('fact_accounts', 14362::bigint, 'EXACT',              'Account fact table should reconcile exactly to the generated source file.'),
        ('fact_branch_monthly_targets', 5424::bigint, 'EXACT', 'Branch target fact table should reconcile exactly to the generated source file.'),
        ('fact_campaign_contacts', 10800::bigint, 'EXACT',     'Campaign contact fact table should reconcile exactly to the generated source file.'),
        ('fact_card_statements', 43470::bigint, 'EXACT',       'Card statement fact table should reconcile exactly to the generated source file.'),
        ('fact_customer_risk_history', 8419::bigint, 'EXACT',  'Customer risk-history fact table should reconcile exactly to the generated source file.'),
        ('fact_fraud_alerts', 1800::bigint, 'EXACT',           'Fraud alert fact table should reconcile exactly to the generated source file.'),
        ('fact_fx_rates', 2192::bigint, 'EXACT',               'FX-rate fact table should reconcile exactly to the generated source file.'),
        ('fact_loan_payments', 29246::bigint, 'EXACT',         'Loan payment fact table should reconcile exactly to the generated source file.'),
        ('fact_loans', 1702::bigint, 'EXACT',                  'Loan fact table should reconcile exactly to the generated source file.'),
        ('fact_monthly_account_balances', 296775::bigint, 'EXACT', 'Monthly balance fact table should reconcile exactly to the generated source file.'),
        ('fact_service_requests', 6500::bigint, 'EXACT',       'Service request fact table should reconcile exactly to the generated source file.'),
        ('fact_transactions', 70000::bigint, 'EXACT',          'Transaction fact table should reconcile exactly to the generated source file.')
),
actual_database_counts AS (
    SELECT 'bridge_account_customers' AS table_name, COUNT(*)::bigint AS actual_rows FROM bridge_account_customers
    UNION ALL SELECT 'dim_branches', COUNT(*)::bigint FROM dim_branches
    UNION ALL SELECT 'dim_campaigns', COUNT(*)::bigint FROM dim_campaigns
    UNION ALL SELECT 'dim_customers', COUNT(*)::bigint FROM dim_customers
    UNION ALL SELECT 'dim_date', COUNT(*)::bigint FROM dim_date
    UNION ALL SELECT 'dim_geography', COUNT(*)::bigint FROM dim_geography
    UNION ALL SELECT 'dim_institutions', COUNT(*)::bigint FROM dim_institutions
    UNION ALL SELECT 'dim_interest_rates', COUNT(*)::bigint FROM dim_interest_rates
    UNION ALL SELECT 'dim_products', COUNT(*)::bigint FROM dim_products
    UNION ALL SELECT 'dim_tax_rates', COUNT(*)::bigint FROM dim_tax_rates
    UNION ALL SELECT 'fact_accounts', COUNT(*)::bigint FROM fact_accounts
    UNION ALL SELECT 'fact_branch_monthly_targets', COUNT(*)::bigint FROM fact_branch_monthly_targets
    UNION ALL SELECT 'fact_campaign_contacts', COUNT(*)::bigint FROM fact_campaign_contacts
    UNION ALL SELECT 'fact_card_statements', COUNT(*)::bigint FROM fact_card_statements
    UNION ALL SELECT 'fact_customer_risk_history', COUNT(*)::bigint FROM fact_customer_risk_history
    UNION ALL SELECT 'fact_fraud_alerts', COUNT(*)::bigint FROM fact_fraud_alerts
    UNION ALL SELECT 'fact_fx_rates', COUNT(*)::bigint FROM fact_fx_rates
    UNION ALL SELECT 'fact_loan_payments', COUNT(*)::bigint FROM fact_loan_payments
    UNION ALL SELECT 'fact_loans', COUNT(*)::bigint FROM fact_loans
    UNION ALL SELECT 'fact_monthly_account_balances', COUNT(*)::bigint FROM fact_monthly_account_balances
    UNION ALL SELECT 'fact_service_requests', COUNT(*)::bigint FROM fact_service_requests
    UNION ALL SELECT 'fact_transactions', COUNT(*)::bigint FROM fact_transactions
),
reconciled_counts AS (
    SELECT
        e.table_name,
        e.expected_rows,
        COALESCE(a.actual_rows, 0::bigint) AS actual_rows,
        COALESCE(a.actual_rows, 0::bigint) - e.expected_rows AS row_count_difference,
        e.reconciliation_rule,
        e.business_note,
        CASE
            WHEN e.reconciliation_rule = 'EXACT'
                 AND COALESCE(a.actual_rows, 0::bigint) = e.expected_rows
                THEN 'PASS'
            WHEN e.reconciliation_rule = 'MINIMUM'
                 AND COALESCE(a.actual_rows, 0::bigint) >= e.expected_rows
                THEN 'PASS'
            ELSE 'FAIL'
        END AS reconciliation_status
    FROM expected_source_counts e
    LEFT JOIN actual_database_counts a
        ON a.table_name = e.table_name
)
SELECT
    table_name,
    expected_rows,
    actual_rows,
    row_count_difference,
    reconciliation_rule,
    reconciliation_status,
    business_note
FROM reconciled_counts;

\echo 'Detailed reconciliation results:'

SELECT
    table_name,
    expected_rows,
    actual_rows,
    row_count_difference,
    reconciliation_rule,
    reconciliation_status
FROM reconciliation_results
ORDER BY
    CASE WHEN reconciliation_status = 'FAIL' THEN 0 ELSE 1 END,
    table_name;

\echo 'Reconciliation summary:'

SELECT
    COUNT(*) AS total_tables_checked,
    COUNT(*) FILTER (WHERE reconciliation_status = 'PASS') AS passed_tables,
    COUNT(*) FILTER (WHERE reconciliation_status = 'FAIL') AS failed_tables
FROM reconciliation_results;

DO $$
DECLARE
    failed_table_count integer;
BEGIN
    SELECT COUNT(*)
    INTO failed_table_count
    FROM reconciliation_results
    WHERE reconciliation_status = 'FAIL';

    IF failed_table_count > 0 THEN
        RAISE EXCEPTION 'Reconciliation failed: % table(s) did not satisfy the expected row-count rule.', failed_table_count;
    END IF;
END $$;

\echo 'Reconciliation checks completed successfully.'
