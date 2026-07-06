\echo 'Running analyst case studies...'

SET search_path TO banking, mart, public;

-- Case 01: Monthly ending balance trend by institution with MoM growth.
WITH monthly AS (
    SELECT
        month_end_date,
        institution_code,
        SUM(ending_balance) AS ending_balance
    FROM mart.v_monthly_institution_kpis
    GROUP BY month_end_date, institution_code
), with_lag AS (
    SELECT
        month_end_date,
        institution_code,
        ending_balance,
        LAG(ending_balance) OVER (PARTITION BY institution_code ORDER BY month_end_date) AS prior_month_balance
    FROM monthly
)
SELECT
    month_end_date,
    institution_code,
    ending_balance,
    prior_month_balance,
    mart.month_over_month_pct(ending_balance, prior_month_balance) AS mom_growth_pct
FROM with_lag
ORDER BY month_end_date DESC, institution_code
LIMIT 36;

-- Case 02: Latest deposit market share by Big 5 institution.
WITH latest_month AS (
    SELECT MAX(month_end_date) AS month_end_date
    FROM mart.v_monthly_institution_kpis
), deposit_balances AS (
    SELECT
        k.institution_code,
        k.institution_name,
        SUM(k.ending_balance) AS deposit_balance
    FROM mart.v_monthly_institution_kpis k
    JOIN latest_month lm ON lm.month_end_date = k.month_end_date
    WHERE k.product_family = 'Deposit'
      AND k.institution_group = 'Big 5'
    GROUP BY k.institution_code, k.institution_name
)
SELECT
    institution_code,
    institution_name,
    deposit_balance,
    ROUND(deposit_balance / SUM(deposit_balance) OVER (), 4) AS big5_deposit_market_share
FROM deposit_balances
ORDER BY deposit_balance DESC;

-- Case 03: Branch target misses across deposit, originations, new accounts, and SLA.
SELECT
    month_end_date,
    institution_code,
    branch_code,
    branch_name,
    province,
    deposit_target_attainment,
    origination_target_attainment,
    new_account_target_attainment,
    sla_target_attainment,
    (CASE WHEN deposit_target_attainment < 1 THEN 1 ELSE 0 END
     + CASE WHEN origination_target_attainment < 1 THEN 1 ELSE 0 END
     + CASE WHEN new_account_target_attainment < 1 THEN 1 ELSE 0 END
     + CASE WHEN sla_target_attainment < 1 THEN 1 ELSE 0 END) AS missed_target_count
FROM mart.v_branch_target_attainment
ORDER BY missed_target_count DESC, month_end_date DESC
LIMIT 50;

-- Case 04: Customer 360 review queue for high-risk or high-opportunity customers.
SELECT
    customer_id,
    customer_number,
    province,
    customer_segment,
    latest_total_balance,
    deposit_balance,
    wealth_balance,
    credit_score,
    risk_segment,
    max_card_utilization,
    max_card_days_past_due,
    recommended_action
FROM mart.v_customer_360
WHERE recommended_action IN ('Review','Wealth Cross-Sell')
ORDER BY
    CASE recommended_action WHEN 'Review' THEN 1 ELSE 2 END,
    latest_total_balance DESC
LIMIT 100;

-- Case 05: Card portfolio risk by institution and province.
SELECT
    statement_month,
    institution_code,
    province,
    COUNT(*) AS statement_count,
    ROUND(AVG(utilization_rate), 4) AS avg_utilization,
    COUNT(*) FILTER (WHERE utilization_rate >= 0.90) AS high_utilization_count,
    COUNT(*) FILTER (WHERE days_past_due > 0) AS delinquent_statement_count,
    ROUND(AVG(CASE WHEN card_review_priority = 'High Review Priority' THEN 1.0 ELSE 0.0 END), 4) AS high_review_rate
FROM mart.v_card_risk
GROUP BY statement_month, institution_code, province
ORDER BY statement_month DESC, high_review_rate DESC
LIMIT 50;

-- Case 06: Loan delinquency buckets by risk segment.
SELECT
    due_month,
    institution_code,
    risk_segment,
    delinquency_bucket,
    COUNT(*) AS payment_count,
    SUM(amount_due) AS amount_due,
    SUM(amount_paid) AS amount_paid,
    SUM(amount_due - amount_paid) AS unpaid_gap,
    ROUND(AVG(days_late), 2) AS avg_days_late
FROM mart.v_loan_delinquency
GROUP BY due_month, institution_code, risk_segment, delinquency_bucket
ORDER BY due_month DESC, unpaid_gap DESC
LIMIT 60;

-- Case 07: Fraud alert false-positive pressure and confirmed loss.
SELECT
    alert_month,
    institution_code,
    alert_type,
    severity,
    SUM(alert_count) AS alert_count,
    SUM(confirmed_fraud_count) AS confirmed_fraud_count,
    SUM(false_positive_count) AS false_positive_count,
    ROUND(SUM(confirmed_fraud_count)::numeric / NULLIF(SUM(alert_count), 0), 4) AS confirmed_rate,
    SUM(estimated_loss_amount) AS estimated_loss_amount
FROM mart.v_fraud_operations
GROUP BY alert_month, institution_code, alert_type, severity
ORDER BY alert_month DESC, estimated_loss_amount DESC, alert_count DESC
LIMIT 50;

-- Case 08: Campaign conversion and estimated ROI by campaign and test group.
SELECT
    campaign_name,
    campaign_type,
    target_product_family,
    test_group,
    SUM(contact_count) AS contact_count,
    SUM(opened_count) AS opened_count,
    SUM(clicked_count) AS clicked_count,
    SUM(converted_count) AS converted_count,
    ROUND(SUM(converted_count)::numeric / NULLIF(SUM(contact_count), 0), 4) AS conversion_rate,
    SUM(estimated_revenue) AS estimated_revenue,
    MAX(budget_amount) AS budget_amount,
    ROUND(SUM(estimated_revenue) / NULLIF(MAX(budget_amount), 0), 4) AS revenue_to_budget_ratio
FROM mart.v_campaign_performance
GROUP BY campaign_name, campaign_type, target_product_family, test_group
ORDER BY revenue_to_budget_ratio DESC, conversion_rate DESC;

-- Case 09: Service SLA root-cause view by request type and channel.
SELECT
    created_month,
    institution_code,
    request_type,
    priority,
    request_channel,
    SUM(request_count) AS request_count,
    SUM(breached_count) AS breached_count,
    ROUND(SUM(breached_count)::numeric / NULLIF(SUM(request_count), 0), 4) AS breach_rate,
    ROUND(AVG(avg_resolution_hours), 2) AS avg_resolution_hours,
    ROUND(AVG(p90_resolution_hours)::numeric, 2) AS avg_p90_resolution_hours
FROM mart.v_service_sla
GROUP BY created_month, institution_code, request_type, priority, request_channel
HAVING SUM(request_count) >= 5
ORDER BY created_month DESC, breach_rate DESC, request_count DESC
LIMIT 50;

-- Case 10: Product cross-sell gap by customer segment.
WITH customer_product_flags AS (
    SELECT
        a.customer_id,
        MAX(CASE WHEN p.product_family = 'Deposit' THEN 1 ELSE 0 END) AS has_deposit,
        MAX(CASE WHEN p.product_family = 'Card' THEN 1 ELSE 0 END) AS has_card,
        MAX(CASE WHEN p.product_family = 'Loan' THEN 1 ELSE 0 END) AS has_loan,
        MAX(CASE WHEN p.product_family = 'Wealth' THEN 1 ELSE 0 END) AS has_wealth
    FROM banking.fact_accounts a
    JOIN banking.dim_products p ON p.product_id = a.product_id
    WHERE a.account_status = 'Open'
    GROUP BY a.customer_id
)
SELECT
    c.customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(has_deposit::numeric), 4) AS deposit_penetration,
    ROUND(AVG(has_card::numeric), 4) AS card_penetration,
    ROUND(AVG(has_loan::numeric), 4) AS loan_penetration,
    ROUND(AVG(has_wealth::numeric), 4) AS wealth_penetration,
    COUNT(*) FILTER (WHERE has_deposit = 1 AND has_wealth = 0) AS deposit_without_wealth_customers
FROM customer_product_flags f
JOIN banking.dim_customers c ON c.customer_id = f.customer_id
GROUP BY c.customer_segment
ORDER BY customers DESC;

-- Case 11: Cohort analysis: account retention by signup year and months since first account.
WITH first_account AS (
    SELECT customer_id, MIN(open_date) AS first_open_date
    FROM banking.fact_accounts
    GROUP BY customer_id
), monthly_activity AS (
    SELECT DISTINCT
        b.customer_id,
        DATE_TRUNC('month', fa.first_open_date)::date AS cohort_month,
        DATE_TRUNC('month', b.month_end_date)::date AS activity_month,
        ((EXTRACT(YEAR FROM b.month_end_date) - EXTRACT(YEAR FROM fa.first_open_date)) * 12
          + (EXTRACT(MONTH FROM b.month_end_date) - EXTRACT(MONTH FROM fa.first_open_date)))::integer AS months_since_first_account
    FROM banking.fact_monthly_account_balances b
    JOIN first_account fa ON fa.customer_id = b.customer_id
    WHERE b.month_end_date >= fa.first_open_date
)
SELECT
    cohort_month,
    months_since_first_account,
    COUNT(DISTINCT customer_id) AS active_customers
FROM monthly_activity
WHERE months_since_first_account BETWEEN 0 AND 24
GROUP BY cohort_month, months_since_first_account
ORDER BY cohort_month, months_since_first_account;

-- Case 12: Top customers by balance contribution using Pareto logic.
WITH latest AS (
    SELECT MAX(month_end_date) AS month_end_date FROM banking.fact_monthly_account_balances
), customer_balances AS (
    SELECT
        b.customer_id,
        SUM(b.ending_balance) AS total_balance
    FROM banking.fact_monthly_account_balances b
    JOIN latest l ON l.month_end_date = b.month_end_date
    GROUP BY b.customer_id
), ranked AS (
    SELECT
        customer_id,
        total_balance,
        SUM(total_balance) OVER (ORDER BY total_balance DESC) AS running_balance,
        SUM(total_balance) OVER () AS portfolio_balance,
        ROW_NUMBER() OVER (ORDER BY total_balance DESC) AS balance_rank
    FROM customer_balances
)
SELECT
    customer_id,
    total_balance,
    balance_rank,
    ROUND(running_balance / NULLIF(portfolio_balance, 0), 4) AS cumulative_balance_share
FROM ranked
WHERE running_balance / NULLIF(portfolio_balance, 0) <= 0.80
ORDER BY balance_rank;

-- Case 13: Balance volatility using rolling windows.
WITH monthly AS (
    SELECT
        customer_id,
        month_end_date,
        SUM(ending_balance) AS total_balance
    FROM banking.fact_monthly_account_balances
    GROUP BY customer_id, month_end_date
), with_change AS (
    SELECT
        customer_id,
        month_end_date,
        total_balance,
        total_balance - LAG(total_balance) OVER (PARTITION BY customer_id ORDER BY month_end_date) AS balance_change
    FROM monthly
)
SELECT
    customer_id,
    month_end_date,
    total_balance,
    balance_change,
    AVG(total_balance) OVER (PARTITION BY customer_id ORDER BY month_end_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_avg_balance,
    STDDEV_SAMP(balance_change) OVER (PARTITION BY customer_id ORDER BY month_end_date ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS rolling_6_month_balance_change_stddev
FROM with_change
ORDER BY customer_id, month_end_date;

-- Case 14: Customer balance tiers using NTILE.
WITH latest AS (
    SELECT MAX(month_end_date) AS month_end_date FROM banking.fact_monthly_account_balances
), customer_balance AS (
    SELECT
        b.customer_id,
        SUM(b.ending_balance) AS total_balance
    FROM banking.fact_monthly_account_balances b
    JOIN latest l ON l.month_end_date = b.month_end_date
    GROUP BY b.customer_id
)
SELECT
    customer_id,
    total_balance,
    NTILE(10) OVER (ORDER BY total_balance DESC) AS balance_decile
FROM customer_balance
ORDER BY balance_decile, total_balance DESC;

-- Case 15: Data-quality scorecard for executive reporting readiness.
WITH dq AS (
    SELECT 'Transactions with missing date key' AS metric, COUNT(*) AS exception_count
    FROM banking.fact_transactions t LEFT JOIN banking.dim_date d ON d.date_key = t.date_key WHERE d.date_key IS NULL
    UNION ALL
    SELECT 'Customers missing postal code', COUNT(*) FROM banking.dim_customers WHERE postal_code IS NULL
    UNION ALL
    SELECT 'Service SLA flag mismatches', COUNT(*) FROM banking.fact_service_requests WHERE (resolution_hours > sla_target_hours AND sla_breached_flag = FALSE) OR (resolution_hours <= sla_target_hours AND sla_breached_flag = TRUE)
    UNION ALL
    SELECT 'Accounts with invalid close date', COUNT(*) FROM banking.fact_accounts WHERE close_date IS NOT NULL AND close_date < open_date
)
SELECT
    metric,
    exception_count,
    CASE WHEN exception_count = 0 THEN 'Pass' WHEN exception_count <= 10 THEN 'Monitor' ELSE 'Investigate' END AS control_status
FROM dq
ORDER BY exception_count DESC;
