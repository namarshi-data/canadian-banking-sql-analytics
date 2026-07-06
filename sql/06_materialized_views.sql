\echo 'Creating materialized views for faster dashboard/reporting queries...'

CREATE MATERIALIZED VIEW IF NOT EXISTS mart.mv_monthly_customer_product_balances AS
SELECT
    b.month_end_date,
    b.customer_id,
    c.customer_segment,
    c.province,
    b.institution_id,
    i.institution_code,
    p.product_family,
    p.product_category,
    COUNT(DISTINCT b.account_id) AS account_count,
    SUM(b.ending_balance) AS ending_balance,
    SUM(b.interest_amount) AS interest_amount,
    SUM(b.fee_amount) AS fee_amount
FROM banking.fact_monthly_account_balances b
JOIN banking.dim_customers c ON c.customer_id = b.customer_id
JOIN banking.dim_institutions i ON i.institution_id = b.institution_id
JOIN banking.dim_products p ON p.product_id = b.product_id
GROUP BY b.month_end_date, b.customer_id, c.customer_segment, c.province, b.institution_id, i.institution_code, p.product_family, p.product_category;

CREATE INDEX IF NOT EXISTS idx_mv_customer_product_month ON mart.mv_monthly_customer_product_balances (month_end_date, customer_id, institution_code, product_family);

CREATE MATERIALIZED VIEW IF NOT EXISTS mart.mv_high_risk_customer_snapshot AS
SELECT
    c.customer_id,
    c.customer_number,
    c.customer_segment,
    c.province,
    c.city,
    c.latest_total_balance,
    c.deposit_balance,
    c.loan_balance,
    c.card_balance,
    c.credit_score,
    c.risk_segment,
    c.max_card_utilization,
    c.max_card_days_past_due,
    c.high_utilization_statement_count,
    c.sla_breach_count,
    c.recommended_action
FROM mart.v_customer_360 c
WHERE c.risk_segment = 'High'
   OR c.max_card_utilization >= 0.90
   OR c.max_card_days_past_due >= 30
   OR c.sla_breach_count >= 3;

CREATE INDEX IF NOT EXISTS idx_mv_high_risk_customer ON mart.mv_high_risk_customer_snapshot (customer_id, province, recommended_action);
