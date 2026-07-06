-- Risk, fraud, and operations analytics

-- High risk customer review queue.
SELECT *
FROM mart.mv_high_risk_customer_snapshot
ORDER BY max_card_days_past_due DESC, max_card_utilization DESC, latest_total_balance DESC
LIMIT 100;

-- Fraud confirmed-rate by severity.
SELECT
    severity,
    SUM(alert_count) AS alert_count,
    SUM(confirmed_fraud_count) AS confirmed_fraud_count,
    ROUND(SUM(confirmed_fraud_count)::numeric / NULLIF(SUM(alert_count), 0), 4) AS confirmed_rate,
    SUM(estimated_loss_amount) AS estimated_loss_amount
FROM mart.v_fraud_operations
GROUP BY severity
ORDER BY confirmed_rate DESC, estimated_loss_amount DESC;

-- SLA breach hotspots.
SELECT
    institution_code,
    province,
    request_type,
    priority,
    SUM(request_count) AS request_count,
    SUM(breached_count) AS breached_count,
    ROUND(SUM(breached_count)::numeric / NULLIF(SUM(request_count), 0), 4) AS breach_rate
FROM mart.v_service_sla
GROUP BY institution_code, province, request_type, priority
HAVING SUM(request_count) >= 10
ORDER BY breach_rate DESC, request_count DESC;
