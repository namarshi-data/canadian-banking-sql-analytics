\echo 'Creating typed source tables...'

SET search_path TO banking, public;

CREATE TABLE IF NOT EXISTS banking.dim_institutions (
    institution_id integer NOT NULL,
    institution_code varchar(10) NOT NULL,
    institution_name varchar(120) NOT NULL,
    institution_group varchar(50) NOT NULL,
    institution_type varchar(50) NOT NULL,
    is_big5 boolean NOT NULL,
    is_dsib boolean NOT NULL,
    is_active boolean NOT NULL,
    headquarters_city varchar(80),
    headquarters_province char(2)
);

CREATE TABLE IF NOT EXISTS banking.dim_geography (
    geo_id integer NOT NULL,
    province char(2) NOT NULL,
    province_name varchar(80) NOT NULL,
    city varchar(80) NOT NULL,
    postal_prefix varchar(3),
    metro_area varchar(120),
    region varchar(80)
);

CREATE TABLE IF NOT EXISTS banking.dim_date (
    date_key integer NOT NULL,
    calendar_date date NOT NULL,
    year integer NOT NULL,
    quarter integer NOT NULL,
    month integer NOT NULL,
    month_name varchar(20) NOT NULL,
    week_of_year integer NOT NULL,
    day_of_week integer NOT NULL,
    is_weekend boolean NOT NULL,
    month_start_date date NOT NULL,
    month_end_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.dim_tax_rates (
    tax_rate_id integer NOT NULL,
    province char(2) NOT NULL,
    province_name varchar(80) NOT NULL,
    total_tax_rate numeric(9,5) NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.dim_interest_rates (
    rate_id integer NOT NULL,
    rate_code varchar(20) NOT NULL,
    rate_name varchar(120) NOT NULL,
    annual_rate numeric(9,6) NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.dim_products (
    product_id integer NOT NULL,
    product_code varchar(30) NOT NULL,
    product_name varchar(120) NOT NULL,
    product_family varchar(40) NOT NULL,
    product_category varchar(60) NOT NULL,
    currency char(3) NOT NULL,
    monthly_fee numeric(12,2) NOT NULL,
    minimum_balance numeric(14,2) NOT NULL,
    base_rate numeric(9,6) NOT NULL,
    is_credit_product boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.dim_campaigns (
    campaign_id integer NOT NULL,
    campaign_name varchar(160) NOT NULL,
    campaign_type varchar(80) NOT NULL,
    target_product_family varchar(40) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    budget_amount numeric(14,2) NOT NULL,
    campaign_description text
);

CREATE TABLE IF NOT EXISTS banking.dim_customers (
    customer_id integer NOT NULL,
    customer_number varchar(30) NOT NULL,
    first_name varchar(80),
    last_name varchar(80),
    email varchar(160),
    phone_last4 varchar(10),
    birth_year integer,
    age_2025 integer,
    customer_segment varchar(80),
    income_band varchar(40),
    employment_status varchar(60),
    geo_id integer,
    province char(2),
    city varchar(80),
    postal_code varchar(10),
    signup_date date NOT NULL,
    onboarding_channel varchar(60),
    is_active boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.dim_branches (
    branch_id integer NOT NULL,
    branch_code varchar(30) NOT NULL,
    institution_id integer NOT NULL,
    geo_id integer NOT NULL,
    branch_name varchar(160) NOT NULL,
    city varchar(80) NOT NULL,
    province char(2) NOT NULL,
    postal_code varchar(10),
    branch_type varchar(80),
    open_date date NOT NULL,
    is_active boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_accounts (
    account_id integer NOT NULL,
    account_number varchar(40) NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    product_id integer NOT NULL,
    open_date date NOT NULL,
    close_date date,
    account_status varchar(30) NOT NULL,
    currency char(3) NOT NULL,
    credit_limit numeric(14,2),
    original_principal numeric(16,2),
    is_joint_account boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.bridge_account_customers (
    account_customer_id integer NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    ownership_role varchar(40) NOT NULL,
    ownership_percent numeric(5,4) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_monthly_account_balances (
    balance_id integer NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    product_id integer NOT NULL,
    date_key integer NOT NULL,
    month_end_date date NOT NULL,
    ending_balance numeric(18,2) NOT NULL,
    interest_amount numeric(14,2) NOT NULL,
    fee_amount numeric(14,2) NOT NULL,
    currency char(3) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_transactions (
    transaction_id integer NOT NULL,
    transaction_reference varchar(40) NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    product_id integer NOT NULL,
    date_key integer NOT NULL,
    transaction_date date NOT NULL,
    transaction_type varchar(50) NOT NULL,
    merchant_category varchar(80),
    amount numeric(14,2) NOT NULL,
    currency char(3) NOT NULL,
    channel varchar(60) NOT NULL,
    transaction_status varchar(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_card_statements (
    statement_id integer NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    date_key integer NOT NULL,
    statement_date date NOT NULL,
    credit_limit numeric(14,2) NOT NULL,
    statement_balance numeric(14,2) NOT NULL,
    purchase_amount numeric(14,2) NOT NULL,
    payment_amount numeric(14,2) NOT NULL,
    interest_charged numeric(14,2) NOT NULL,
    fee_charged numeric(14,2) NOT NULL,
    minimum_payment_due numeric(14,2) NOT NULL,
    days_past_due integer NOT NULL,
    utilization_rate numeric(9,4) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_customer_risk_history (
    risk_history_id integer NOT NULL,
    customer_id integer NOT NULL,
    credit_score_band varchar(40) NOT NULL,
    -- Nullable by design: some customers are new-to-credit, thin-file, or otherwise not scoreable.
    credit_score integer,
    risk_segment varchar(40) NOT NULL,
    income_band varchar(40),
    employment_status varchar(60),
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL,
    is_current boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_loans (
    loan_id integer NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    product_id integer NOT NULL,
    origination_date date NOT NULL,
    close_date date,
    original_principal numeric(16,2) NOT NULL,
    annual_interest_rate numeric(9,6) NOT NULL,
    term_months integer NOT NULL,
    scheduled_monthly_payment numeric(14,2) NOT NULL,
    loan_status varchar(40) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_loan_payments (
    loan_payment_id integer NOT NULL,
    loan_id integer NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    date_key integer NOT NULL,
    due_date date NOT NULL,
    paid_date date,
    amount_due numeric(14,2) NOT NULL,
    amount_paid numeric(14,2) NOT NULL,
    days_late integer NOT NULL,
    principal_component numeric(14,2) NOT NULL,
    interest_component numeric(14,2) NOT NULL,
    payment_status varchar(40) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_fraud_alerts (
    fraud_alert_id integer NOT NULL,
    transaction_id integer NOT NULL,
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    alert_date date NOT NULL,
    alert_type varchar(80) NOT NULL,
    severity varchar(20) NOT NULL,
    confirmed_fraud_flag boolean NOT NULL,
    estimated_loss_amount numeric(14,2) NOT NULL,
    resolution_status varchar(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_fx_rates (
    fx_rate_id integer NOT NULL,
    date_key integer NOT NULL,
    rate_date date NOT NULL,
    from_currency char(3) NOT NULL,
    to_currency char(3) NOT NULL,
    exchange_rate numeric(12,6) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_branch_monthly_targets (
    target_id integer NOT NULL,
    branch_id integer NOT NULL,
    institution_id integer NOT NULL,
    date_key integer NOT NULL,
    month_end_date date NOT NULL,
    deposit_balance_target numeric(18,2) NOT NULL,
    loan_originations_target numeric(18,2) NOT NULL,
    new_accounts_target integer NOT NULL,
    service_sla_target numeric(6,4) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_campaign_contacts (
    contact_id integer NOT NULL,
    campaign_id integer NOT NULL,
    -- Nullable by design: campaign contacts can include prospects or anonymous/pre-acquisition leads.
    customer_id integer,
    contact_date date NOT NULL,
    contact_channel varchar(60) NOT NULL,
    opened_flag boolean NOT NULL,
    clicked_flag boolean NOT NULL,
    converted_flag boolean NOT NULL,
    estimated_revenue numeric(14,2) NOT NULL,
    test_group varchar(40) NOT NULL
);

CREATE TABLE IF NOT EXISTS banking.fact_service_requests (
    service_request_id integer NOT NULL,
    service_request_number varchar(40) NOT NULL,
    customer_id integer NOT NULL,
    account_id integer NOT NULL,
    institution_id integer NOT NULL,
    branch_id integer NOT NULL,
    created_date date NOT NULL,
    request_type varchar(80) NOT NULL,
    priority varchar(20) NOT NULL,
    sla_target_hours integer NOT NULL,
    resolution_hours numeric(10,2) NOT NULL,
    sla_breached_flag boolean NOT NULL,
    request_status varchar(40) NOT NULL,
    request_channel varchar(60) NOT NULL
);
