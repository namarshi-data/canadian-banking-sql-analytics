\echo 'Loading CSV files into PostgreSQL tables...'
SET search_path TO banking, public;

TRUNCATE TABLE
    banking.fact_service_requests,
    banking.fact_campaign_contacts,
    banking.fact_branch_monthly_targets,
    banking.fact_fx_rates,
    banking.fact_fraud_alerts,
    banking.fact_loan_payments,
    banking.fact_loans,
    banking.fact_customer_risk_history,
    banking.fact_card_statements,
    banking.fact_transactions,
    banking.fact_monthly_account_balances,
    banking.bridge_account_customers,
    banking.fact_accounts,
    banking.dim_branches,
    banking.dim_customers,
    banking.dim_campaigns,
    banking.dim_products,
    banking.dim_interest_rates,
    banking.dim_tax_rates,
    banking.dim_date,
    banking.dim_geography,
    banking.dim_institutions
RESTART IDENTITY CASCADE;

COPY banking.dim_institutions FROM '/data/raw/dim_institutions.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_geography FROM '/data/raw/dim_geography.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_date FROM '/data/raw/dim_date.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_tax_rates FROM '/data/raw/dim_tax_rates.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_interest_rates FROM '/data/raw/dim_interest_rates.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_products FROM '/data/raw/dim_products.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_campaigns FROM '/data/raw/dim_campaigns.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_customers FROM '/data/raw/dim_customers.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.dim_branches FROM '/data/raw/dim_branches.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_accounts FROM '/data/raw/fact_accounts.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.bridge_account_customers FROM '/data/raw/bridge_account_customers.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_monthly_account_balances FROM '/data/raw/fact_monthly_account_balances.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');

-- Stage transactions before loading into the constrained fact table.
-- This lets the load standardize date_key and extend dim_date before foreign keys are enforced.
DROP TABLE IF EXISTS pg_temp.stg_fact_transactions;
CREATE TEMP TABLE stg_fact_transactions (LIKE banking.fact_transactions);

COPY stg_fact_transactions FROM '/data/raw/fact_transactions.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');

WITH standardized_transaction_date_keys AS (
    UPDATE stg_fact_transactions
    SET date_key = TO_CHAR(transaction_date, 'YYYYMMDD')::integer
    WHERE transaction_date IS NOT NULL
      AND date_key IS DISTINCT FROM TO_CHAR(transaction_date, 'YYYYMMDD')::integer
    RETURNING 1
)
SELECT COUNT(*) AS standardized_transaction_date_keys
FROM standardized_transaction_date_keys;

-- Extend the conformed date dimension for valid transaction dates that are outside
-- the original synthetic calendar range, preserving transactions instead of deleting rows.
WITH missing_transaction_dates AS (
    SELECT DISTINCT
        t.date_key,
        t.transaction_date AS calendar_date
    FROM stg_fact_transactions t
    LEFT JOIN banking.dim_date d
        ON d.date_key = t.date_key
    WHERE d.date_key IS NULL
      AND t.transaction_date IS NOT NULL
      AND t.date_key = TO_CHAR(t.transaction_date, 'YYYYMMDD')::integer
), inserted_dates AS (
    INSERT INTO banking.dim_date (
        date_key,
        calendar_date,
        year,
        quarter,
        month,
        month_name,
        week_of_year,
        day_of_week,
        is_weekend,
        month_start_date,
        month_end_date
    )
    SELECT
        date_key,
        calendar_date,
        EXTRACT(YEAR FROM calendar_date)::integer,
        EXTRACT(QUARTER FROM calendar_date)::integer,
        EXTRACT(MONTH FROM calendar_date)::integer,
        TRIM(TO_CHAR(calendar_date, 'Month')),
        EXTRACT(WEEK FROM calendar_date)::integer,
        EXTRACT(ISODOW FROM calendar_date)::integer,
        EXTRACT(ISODOW FROM calendar_date)::integer IN (6, 7),
        DATE_TRUNC('month', calendar_date)::date,
        (DATE_TRUNC('month', calendar_date) + INTERVAL '1 month' - INTERVAL '1 day')::date
    FROM missing_transaction_dates
    RETURNING 1
)
SELECT COUNT(*) AS inserted_missing_transaction_dates
FROM inserted_dates;

INSERT INTO banking.fact_transactions (
    transaction_id,
    transaction_reference,
    account_id,
    customer_id,
    institution_id,
    branch_id,
    product_id,
    date_key,
    transaction_date,
    transaction_type,
    merchant_category,
    amount,
    currency,
    channel,
    transaction_status
)
SELECT
    transaction_id,
    transaction_reference,
    account_id,
    customer_id,
    institution_id,
    branch_id,
    product_id,
    date_key,
    transaction_date,
    transaction_type,
    merchant_category,
    amount,
    currency,
    channel,
    transaction_status
FROM stg_fact_transactions;

COPY banking.fact_card_statements FROM '/data/raw/fact_card_statements.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_customer_risk_history FROM '/data/raw/fact_customer_risk_history.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_loans FROM '/data/raw/fact_loans.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_loan_payments FROM '/data/raw/fact_loan_payments.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_fraud_alerts FROM '/data/raw/fact_fraud_alerts.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_fx_rates FROM '/data/raw/fact_fx_rates.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_branch_monthly_targets FROM '/data/raw/fact_branch_monthly_targets.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_campaign_contacts FROM '/data/raw/fact_campaign_contacts.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');
COPY banking.fact_service_requests FROM '/data/raw/fact_service_requests.csv' WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');

\echo 'Applying post-load data-quality standardization...'

-- Standardize null bureau-score records for transparent risk segmentation.
-- Customers without an available bureau score are retained, but the band must
-- be explicitly labeled as No Score so downstream risk views and assertions
-- do not treat them as unlabeled records.
WITH standardized_no_score_records AS (
    UPDATE banking.fact_customer_risk_history
    SET credit_score_band = 'No Score'
    WHERE credit_score IS NULL
      AND credit_score_band IS DISTINCT FROM 'No Score'
    RETURNING 1
)
SELECT COUNT(*) AS standardized_no_score_records
FROM standardized_no_score_records;

-- Recalculate SLA breach flags from the business rule: a request breaches SLA
-- only when resolution time is greater than the target window.
WITH corrected_sla_flags AS (
    UPDATE banking.fact_service_requests
    SET sla_breached_flag = (resolution_hours > sla_target_hours)
    WHERE sla_breached_flag IS DISTINCT FROM (resolution_hours > sla_target_hours)
    RETURNING 1
)
SELECT COUNT(*) AS corrected_service_sla_flags
FROM corrected_sla_flags;

\echo 'CSV load complete.'
