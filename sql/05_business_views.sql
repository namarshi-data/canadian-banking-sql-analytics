\echo 'Creating reusable business analytics views...'

CREATE SCHEMA IF NOT EXISTS mart;
SET search_path TO banking, mart, public;

CREATE OR REPLACE VIEW mart.v_monthly_institution_kpis AS
SELECT
    b.month_end_date,
    d.year,
    d.quarter,
    d.month,
    i.institution_code,
    i.institution_name,
    i.institution_group,
    p.product_family,
    p.product_category,
    COUNT(DISTINCT b.customer_id) AS active_customers,
    COUNT(DISTINCT b.account_id) AS active_accounts,
    SUM(b.ending_balance) AS ending_balance,
    SUM(b.interest_amount) AS interest_amount,
    SUM(b.fee_amount) AS fee_amount,
    AVG(b.ending_balance) AS avg_account_balance
FROM banking.fact_monthly_account_balances b
JOIN banking.dim_institutions i ON i.institution_id = b.institution_id
JOIN banking.dim_products p ON p.product_id = b.product_id
LEFT JOIN banking.dim_date d ON d.date_key = b.date_key
GROUP BY
    b.month_end_date,
    d.year,
    d.quarter,
    d.month,
    i.institution_code,
    i.institution_name,
    i.institution_group,
    p.product_family,
    p.product_category;

CREATE OR REPLACE VIEW mart.v_customer_360 AS
WITH latest_balance_month AS (
    SELECT MAX(month_end_date) AS month_end_date
    FROM banking.fact_monthly_account_balances
), balance_snapshot AS (
    SELECT
        b.customer_id,
        COUNT(DISTINCT b.account_id) AS active_balance_accounts,
        SUM(b.ending_balance) AS latest_total_balance,
        SUM(CASE WHEN p.product_family = 'Deposit' THEN b.ending_balance ELSE 0 END) AS deposit_balance,
        SUM(CASE WHEN p.product_family = 'Wealth' THEN b.ending_balance ELSE 0 END) AS wealth_balance,
        SUM(CASE WHEN p.product_family = 'Card' THEN b.ending_balance ELSE 0 END) AS card_balance,
        SUM(CASE WHEN p.product_family = 'Loan' THEN b.ending_balance ELSE 0 END) AS loan_balance
    FROM banking.fact_monthly_account_balances b
    JOIN latest_balance_month lbm ON lbm.month_end_date = b.month_end_date
    JOIN banking.dim_products p ON p.product_id = b.product_id
    GROUP BY b.customer_id
), account_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_accounts,
        COUNT(*) FILTER (WHERE account_status = 'Open') AS open_accounts,
        COUNT(*) FILTER (WHERE is_joint_account) AS joint_accounts,
        MIN(open_date) AS first_account_open_date,
        MAX(open_date) AS latest_account_open_date
    FROM banking.fact_accounts
    GROUP BY customer_id
), current_risk AS (
    SELECT
        customer_id,
        credit_score,
        credit_score_band,
        risk_segment
    FROM banking.fact_customer_risk_history
    WHERE is_current = TRUE
), card_risk AS (
    SELECT
        customer_id,
        MAX(utilization_rate) AS max_card_utilization,
        MAX(days_past_due) AS max_card_days_past_due,
        COUNT(*) FILTER (WHERE utilization_rate >= 0.80) AS high_utilization_statement_count
    FROM banking.fact_card_statements
    GROUP BY customer_id
), service_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS service_request_count,
        COUNT(*) FILTER (WHERE sla_breached_flag) AS sla_breach_count
    FROM banking.fact_service_requests
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_number,
    c.customer_segment,
    c.income_band,
    c.employment_status,
    c.province,
    c.city,
    c.signup_date,
    c.onboarding_channel,
    COALESCE(a.total_accounts, 0) AS total_accounts,
    COALESCE(a.open_accounts, 0) AS open_accounts,
    COALESCE(a.joint_accounts, 0) AS joint_accounts,
    a.first_account_open_date,
    a.latest_account_open_date,
    COALESCE(bs.active_balance_accounts, 0) AS active_balance_accounts,
    COALESCE(bs.latest_total_balance, 0) AS latest_total_balance,
    COALESCE(bs.deposit_balance, 0) AS deposit_balance,
    COALESCE(bs.wealth_balance, 0) AS wealth_balance,
    COALESCE(bs.card_balance, 0) AS card_balance,
    COALESCE(bs.loan_balance, 0) AS loan_balance,
    cr.credit_score,
    cr.credit_score_band,
    cr.risk_segment,
    COALESCE(card.max_card_utilization, 0) AS max_card_utilization,
    COALESCE(card.max_card_days_past_due, 0) AS max_card_days_past_due,
    COALESCE(card.high_utilization_statement_count, 0) AS high_utilization_statement_count,
    COALESCE(s.service_request_count, 0) AS service_request_count,
    COALESCE(s.sla_breach_count, 0) AS sla_breach_count,
    CASE
        WHEN cr.risk_segment = 'High' OR COALESCE(card.max_card_days_past_due, 0) >= 30 OR COALESCE(card.max_card_utilization, 0) >= 0.90 THEN 'Review'
        WHEN COALESCE(bs.deposit_balance, 0) >= 100000 AND COALESCE(bs.wealth_balance, 0) = 0 THEN 'Wealth Cross-Sell'
        WHEN COALESCE(a.open_accounts, 0) = 1 THEN 'Relationship Deepening'
        ELSE 'Monitor'
    END AS recommended_action
FROM banking.dim_customers c
LEFT JOIN account_summary a ON a.customer_id = c.customer_id
LEFT JOIN balance_snapshot bs ON bs.customer_id = c.customer_id
LEFT JOIN current_risk cr ON cr.customer_id = c.customer_id
LEFT JOIN card_risk card ON card.customer_id = c.customer_id
LEFT JOIN service_summary s ON s.customer_id = c.customer_id;

CREATE OR REPLACE VIEW mart.v_branch_target_attainment AS
WITH actual_balances AS (
    SELECT
        branch_id,
        institution_id,
        month_end_date,
        SUM(CASE WHEN p.product_family = 'Deposit' THEN b.ending_balance ELSE 0 END) AS actual_deposit_balance
    FROM banking.fact_monthly_account_balances b
    JOIN banking.dim_products p ON p.product_id = b.product_id
    GROUP BY branch_id, institution_id, month_end_date
), actual_originations AS (
    SELECT
        branch_id,
        institution_id,
        DATE_TRUNC('month', origination_date)::date + INTERVAL '1 month - 1 day' AS month_end_date,
        SUM(original_principal) AS actual_loan_originations
    FROM banking.fact_loans
    GROUP BY branch_id, institution_id, DATE_TRUNC('month', origination_date)::date + INTERVAL '1 month - 1 day'
), actual_new_accounts AS (
    SELECT
        branch_id,
        institution_id,
        DATE_TRUNC('month', open_date)::date + INTERVAL '1 month - 1 day' AS month_end_date,
        COUNT(*) AS actual_new_accounts
    FROM banking.fact_accounts
    GROUP BY branch_id, institution_id, DATE_TRUNC('month', open_date)::date + INTERVAL '1 month - 1 day'
), service_actuals AS (
    SELECT
        branch_id,
        institution_id,
        DATE_TRUNC('month', created_date)::date + INTERVAL '1 month - 1 day' AS month_end_date,
        1.0 - AVG(CASE WHEN sla_breached_flag THEN 1.0 ELSE 0.0 END) AS actual_sla_attainment
    FROM banking.fact_service_requests
    GROUP BY branch_id, institution_id, DATE_TRUNC('month', created_date)::date + INTERVAL '1 month - 1 day'
)
SELECT
    t.month_end_date,
    i.institution_code,
    i.institution_name,
    br.branch_code,
    br.branch_name,
    br.city,
    br.province,
    t.deposit_balance_target,
    COALESCE(ab.actual_deposit_balance, 0) AS actual_deposit_balance,
    ROUND(COALESCE(ab.actual_deposit_balance, 0) / NULLIF(t.deposit_balance_target, 0), 4) AS deposit_target_attainment,
    t.loan_originations_target,
    COALESCE(ao.actual_loan_originations, 0) AS actual_loan_originations,
    ROUND(COALESCE(ao.actual_loan_originations, 0) / NULLIF(t.loan_originations_target, 0), 4) AS origination_target_attainment,
    t.new_accounts_target,
    COALESCE(ana.actual_new_accounts, 0) AS actual_new_accounts,
    ROUND(COALESCE(ana.actual_new_accounts, 0)::numeric / NULLIF(t.new_accounts_target, 0), 4) AS new_account_target_attainment,
    t.service_sla_target,
    COALESCE(sa.actual_sla_attainment, 1.0) AS actual_sla_attainment,
    ROUND(COALESCE(sa.actual_sla_attainment, 1.0) / NULLIF(t.service_sla_target, 0), 4) AS sla_target_attainment
FROM banking.fact_branch_monthly_targets t
JOIN banking.dim_branches br ON br.branch_id = t.branch_id
JOIN banking.dim_institutions i ON i.institution_id = t.institution_id
LEFT JOIN actual_balances ab ON ab.branch_id = t.branch_id AND ab.institution_id = t.institution_id AND ab.month_end_date = t.month_end_date
LEFT JOIN actual_originations ao ON ao.branch_id = t.branch_id AND ao.institution_id = t.institution_id AND ao.month_end_date = t.month_end_date
LEFT JOIN actual_new_accounts ana ON ana.branch_id = t.branch_id AND ana.institution_id = t.institution_id AND ana.month_end_date = t.month_end_date
LEFT JOIN service_actuals sa ON sa.branch_id = t.branch_id AND sa.institution_id = t.institution_id AND sa.month_end_date = t.month_end_date;

CREATE OR REPLACE VIEW mart.v_loan_delinquency AS
SELECT
    p.due_date,
    DATE_TRUNC('month', p.due_date)::date AS due_month,
    i.institution_code,
    br.province,
    br.city,
    l.loan_id,
    l.account_id,
    l.customer_id,
    pr.product_name,
    pr.product_category,
    l.original_principal,
    l.annual_interest_rate,
    l.term_months,
    l.loan_status,
    rh.credit_score,
    rh.risk_segment,
    p.amount_due,
    p.amount_paid,
    p.days_late,
    p.payment_status,
    CASE
        WHEN p.days_late >= 90 THEN '90+ DPD'
        WHEN p.days_late >= 60 THEN '60-89 DPD'
        WHEN p.days_late >= 30 THEN '30-59 DPD'
        WHEN p.days_late > 0 THEN '1-29 DPD'
        ELSE 'Current'
    END AS delinquency_bucket
FROM banking.fact_loan_payments p
JOIN banking.fact_loans l ON l.loan_id = p.loan_id
JOIN banking.dim_institutions i ON i.institution_id = p.institution_id
JOIN banking.dim_branches br ON br.branch_id = l.branch_id
JOIN banking.dim_products pr ON pr.product_id = l.product_id
LEFT JOIN banking.fact_customer_risk_history rh ON rh.customer_id = p.customer_id AND rh.is_current = TRUE;

CREATE OR REPLACE VIEW mart.v_card_risk AS
SELECT
    cs.statement_date,
    DATE_TRUNC('month', cs.statement_date)::date AS statement_month,
    i.institution_code,
    br.province,
    br.city,
    cs.customer_id,
    cs.account_id,
    cs.credit_limit,
    cs.statement_balance,
    cs.purchase_amount,
    cs.payment_amount,
    cs.interest_charged,
    cs.fee_charged,
    cs.minimum_payment_due,
    cs.days_past_due,
    cs.utilization_rate,
    rh.credit_score,
    rh.risk_segment,
    CASE
        WHEN cs.days_past_due >= 30 OR cs.utilization_rate >= 0.90 OR rh.risk_segment = 'High' THEN 'High Review Priority'
        WHEN cs.utilization_rate >= 0.75 THEN 'Medium Review Priority'
        ELSE 'Low Review Priority'
    END AS card_review_priority
FROM banking.fact_card_statements cs
JOIN banking.dim_institutions i ON i.institution_id = cs.institution_id
JOIN banking.dim_branches br ON br.branch_id = cs.branch_id
LEFT JOIN banking.fact_customer_risk_history rh ON rh.customer_id = cs.customer_id AND rh.is_current = TRUE;

CREATE OR REPLACE VIEW mart.v_fraud_operations AS
SELECT
    DATE_TRUNC('month', fa.alert_date)::date AS alert_month,
    i.institution_code,
    br.province,
    fa.alert_type,
    fa.severity,
    fa.resolution_status,
    COUNT(*) AS alert_count,
    COUNT(*) FILTER (WHERE fa.confirmed_fraud_flag) AS confirmed_fraud_count,
    COUNT(*) FILTER (WHERE NOT fa.confirmed_fraud_flag) AS false_positive_count,
    ROUND(AVG(CASE WHEN fa.confirmed_fraud_flag THEN 1.0 ELSE 0.0 END), 4) AS confirmed_fraud_rate,
    SUM(fa.estimated_loss_amount) AS estimated_loss_amount
FROM banking.fact_fraud_alerts fa
JOIN banking.dim_institutions i ON i.institution_id = fa.institution_id
JOIN banking.dim_branches br ON br.branch_id = fa.branch_id
GROUP BY DATE_TRUNC('month', fa.alert_date)::date, i.institution_code, br.province, fa.alert_type, fa.severity, fa.resolution_status;

CREATE OR REPLACE VIEW mart.v_campaign_performance AS
SELECT
    c.campaign_id,
    c.campaign_name,
    c.campaign_type,
    c.target_product_family,
    c.start_date,
    c.end_date,
    c.budget_amount,
    cc.test_group,
    cc.contact_channel,
    COUNT(*) AS contact_count,
    COUNT(*) FILTER (WHERE opened_flag) AS opened_count,
    COUNT(*) FILTER (WHERE clicked_flag) AS clicked_count,
    COUNT(*) FILTER (WHERE converted_flag) AS converted_count,
    ROUND(AVG(CASE WHEN opened_flag THEN 1.0 ELSE 0.0 END), 4) AS open_rate,
    ROUND(AVG(CASE WHEN clicked_flag THEN 1.0 ELSE 0.0 END), 4) AS click_rate,
    ROUND(AVG(CASE WHEN converted_flag THEN 1.0 ELSE 0.0 END), 4) AS conversion_rate,
    SUM(cc.estimated_revenue) AS estimated_revenue,
    ROUND(SUM(cc.estimated_revenue) / NULLIF(c.budget_amount, 0), 4) AS revenue_to_budget_ratio
FROM banking.fact_campaign_contacts cc
JOIN banking.dim_campaigns c ON c.campaign_id = cc.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.campaign_type, c.target_product_family, c.start_date, c.end_date, c.budget_amount, cc.test_group, cc.contact_channel;

CREATE OR REPLACE VIEW mart.v_service_sla AS
SELECT
    DATE_TRUNC('month', sr.created_date)::date AS created_month,
    i.institution_code,
    br.province,
    br.city,
    sr.request_type,
    sr.priority,
    sr.request_channel,
    sr.request_status,
    COUNT(*) AS request_count,
    COUNT(*) FILTER (WHERE sr.sla_breached_flag) AS breached_count,
    ROUND(AVG(CASE WHEN sr.sla_breached_flag THEN 1.0 ELSE 0.0 END), 4) AS breach_rate,
    ROUND(AVG(sr.resolution_hours), 2) AS avg_resolution_hours,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY sr.resolution_hours) AS median_resolution_hours,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY sr.resolution_hours) AS p90_resolution_hours
FROM banking.fact_service_requests sr
JOIN banking.dim_institutions i ON i.institution_id = sr.institution_id
JOIN banking.dim_branches br ON br.branch_id = sr.branch_id
GROUP BY DATE_TRUNC('month', sr.created_date)::date, i.institution_code, br.province, br.city, sr.request_type, sr.priority, sr.request_channel, sr.request_status;
