\echo 'Running optional advanced SQL pattern examples...'

SET search_path TO banking, mart, audit, public;

-- Purpose
-- -------
-- These optional examples show advanced patterns that are useful in interviews and
-- production analytics work. They are read-only and can be run after the main build.

-- 1. Recursive CTE: build a compact date spine for analysis.
WITH RECURSIVE date_spine(calendar_date) AS (
    SELECT DATE '2025-01-01'
    UNION ALL
    SELECT calendar_date + 1
    FROM date_spine
    WHERE calendar_date < DATE '2025-01-31'
)
SELECT
    calendar_date,
    EXTRACT(ISODOW FROM calendar_date) AS iso_day_of_week,
    CASE WHEN EXTRACT(ISODOW FROM calendar_date) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_spine
ORDER BY calendar_date;

-- 2. Conditional aggregation pivot: product-family balances by institution.
-- Product-family values come directly from dim_products: Deposit, Card, Loan, and Wealth.
SELECT
    i.institution_name,
    ROUND(COALESCE(SUM(b.ending_balance) FILTER (WHERE p.product_family = 'Deposit'), 0), 2) AS deposit_balance,
    ROUND(COALESCE(SUM(b.ending_balance) FILTER (WHERE p.product_family = 'Card'), 0), 2) AS card_balance,
    ROUND(COALESCE(SUM(b.ending_balance) FILTER (WHERE p.product_family = 'Loan'), 0), 2) AS loan_balance,
    ROUND(COALESCE(SUM(b.ending_balance) FILTER (WHERE p.product_family = 'Wealth'), 0), 2) AS wealth_balance,
    ROUND(SUM(b.ending_balance), 2) AS total_balance
FROM banking.fact_monthly_account_balances b
JOIN banking.dim_products p
    ON p.product_id = b.product_id
JOIN banking.dim_institutions i
    ON i.institution_id = b.institution_id
WHERE b.month_end_date = DATE '2025-12-31'
GROUP BY i.institution_name
ORDER BY total_balance DESC;

-- 3. Unpivot pattern using CROSS JOIN LATERAL.
WITH branch_month AS (
    SELECT
        branch_id,
        institution_id,
        month_end_date,
        deposit_balance_target,
        loan_originations_target,
        new_accounts_target::numeric AS new_accounts_target,
        service_sla_target
    FROM banking.fact_branch_monthly_targets
    WHERE month_end_date = DATE '2025-12-31'
    LIMIT 25
)
SELECT
    branch_id,
    institution_id,
    month_end_date,
    metric_name,
    metric_value
FROM branch_month
CROSS JOIN LATERAL (
    VALUES
        ('deposit_balance_target', deposit_balance_target),
        ('loan_originations_target', loan_originations_target),
        ('new_accounts_target', new_accounts_target),
        ('service_sla_target', service_sla_target)
) AS unpivoted(metric_name, metric_value)
ORDER BY branch_id, metric_name;

-- 4. LATERAL join: latest risk record per customer.
SELECT
    c.customer_id,
    c.customer_segment,
    latest_risk.credit_score,
    latest_risk.credit_score_band,
    latest_risk.risk_segment,
    latest_risk.effective_start_date
FROM banking.dim_customers c
LEFT JOIN LATERAL (
    SELECT
        r.credit_score,
        r.credit_score_band,
        r.risk_segment,
        r.effective_start_date
    FROM banking.fact_customer_risk_history r
    WHERE r.customer_id = c.customer_id
    ORDER BY r.is_current DESC, r.effective_start_date DESC, r.risk_history_id DESC
    LIMIT 1
) latest_risk ON TRUE
ORDER BY c.customer_id
LIMIT 100;

-- 5. Statistical summary: service resolution distribution by priority.
SELECT
    priority,
    COUNT(*) AS request_count,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY resolution_hours)::numeric, 2) AS median_resolution_hours,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY resolution_hours)::numeric, 2) AS p90_resolution_hours,
    ROUND(STDDEV_POP(resolution_hours), 2) AS stddev_resolution_hours
FROM banking.fact_service_requests
GROUP BY priority
ORDER BY request_count DESC;

-- 6. Array aggregation: product family footprint per customer segment.
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customers,
    ARRAY_AGG(DISTINCT p.product_family ORDER BY p.product_family) AS product_families_used
FROM banking.dim_customers c
JOIN banking.fact_accounts a
    ON a.customer_id = c.customer_id
JOIN banking.dim_products p
    ON p.product_id = a.product_id
GROUP BY c.customer_segment
ORDER BY customers DESC;

-- 7. JSONB object creation: compact customer 360 sample for API-style consumption.
SELECT
    jsonb_build_object(
        'customer_id', c.customer_id,
        'customer_segment', c.customer_segment,
        'province', c.province,
        'active_accounts', COUNT(DISTINCT a.account_id),
        'product_families', ARRAY_AGG(DISTINCT p.product_family ORDER BY p.product_family)
    ) AS customer_360_json
FROM banking.dim_customers c
LEFT JOIN banking.fact_accounts a
    ON a.customer_id = c.customer_id
LEFT JOIN banking.dim_products p
    ON p.product_id = a.product_id
WHERE c.customer_id BETWEEN 1 AND 20
GROUP BY c.customer_id, c.customer_segment, c.province
ORDER BY c.customer_id;

\echo 'Optional advanced SQL pattern examples complete.'
