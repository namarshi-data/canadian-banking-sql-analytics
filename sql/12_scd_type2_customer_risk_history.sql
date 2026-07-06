\echo 'Demonstrating SCD Type 2 customer risk history pattern...'

SET search_path TO banking, mart, audit, public;

-- Purpose
-- -------
-- This script demonstrates a safe Slowly Changing Dimension Type 2 pattern using the
-- customer risk history table. It stages incoming changes, identifies changed rows,
-- expires the previous current record, inserts the new current record, validates the
-- one-current-record rule, and rolls back at the end so the portfolio dataset remains unchanged.

BEGIN;

-- 1. Stage incoming source-system changes.
-- In a real pipeline, this would come from a bureau/risk feed or upstream risk model output.
CREATE TEMP TABLE tmp_customer_risk_changes AS
WITH current_risk AS (
    SELECT
        customer_id,
        credit_score,
        risk_segment,
        income_band,
        employment_status,
        CASE
            WHEN credit_score IS NULL THEN 680
            WHEN credit_score >= 880 THEN credit_score - 15
            ELSE credit_score + 10
        END AS new_credit_score
    FROM banking.fact_customer_risk_history
    WHERE is_current = TRUE
    ORDER BY customer_id
    LIMIT 5
)
SELECT
    customer_id,
    new_credit_score,
    CASE
        WHEN new_credit_score IS NULL THEN 'No Score'
        WHEN new_credit_score >= 800 THEN 'Excellent'
        WHEN new_credit_score >= 740 THEN 'Very Good'
        WHEN new_credit_score >= 670 THEN 'Good'
        WHEN new_credit_score >= 580 THEN 'Fair'
        ELSE 'Poor'
    END AS new_credit_score_band,
    CASE
        WHEN new_credit_score IS NULL THEN 'New/Thin File'
        WHEN new_credit_score >= 740 THEN 'Low'
        WHEN new_credit_score >= 670 THEN 'Medium'
        ELSE 'High'
    END AS new_risk_segment,
    income_band,
    employment_status,
    CURRENT_DATE AS new_effective_start_date
FROM current_risk;

-- 2. Review incoming staged changes before applying them.
SELECT *
FROM tmp_customer_risk_changes
ORDER BY customer_id;

-- 3. Store exactly which current records changed. This avoids accidental inserts from
-- older historical rows that happen to share the same end date.
CREATE TEMP TABLE tmp_changed_customer_risk_records AS
SELECT
    current_risk.risk_history_id,
    staged.customer_id,
    staged.new_credit_score,
    staged.new_credit_score_band,
    staged.new_risk_segment,
    staged.income_band,
    staged.employment_status,
    staged.new_effective_start_date
FROM banking.fact_customer_risk_history current_risk
JOIN tmp_customer_risk_changes staged
    ON staged.customer_id = current_risk.customer_id
WHERE current_risk.is_current = TRUE
  AND (
        current_risk.credit_score IS DISTINCT FROM staged.new_credit_score
     OR current_risk.credit_score_band IS DISTINCT FROM staged.new_credit_score_band
     OR current_risk.risk_segment IS DISTINCT FROM staged.new_risk_segment
  );

-- 4. Expire current records only when the incoming attributes changed.
UPDATE banking.fact_customer_risk_history current_risk
SET
    effective_end_date = changed.new_effective_start_date - 1,
    is_current = FALSE
FROM tmp_changed_customer_risk_records changed
WHERE current_risk.risk_history_id = changed.risk_history_id;

-- 5. Insert new current records for changed customers.
WITH numbered_inserts AS (
    SELECT
        (SELECT COALESCE(MAX(risk_history_id), 0) FROM banking.fact_customer_risk_history)
        + ROW_NUMBER() OVER (ORDER BY customer_id) AS new_risk_history_id,
        customer_id,
        new_credit_score,
        new_credit_score_band,
        new_risk_segment,
        income_band,
        employment_status,
        new_effective_start_date
    FROM tmp_changed_customer_risk_records
)
INSERT INTO banking.fact_customer_risk_history (
    risk_history_id,
    customer_id,
    credit_score_band,
    credit_score,
    risk_segment,
    income_band,
    employment_status,
    effective_start_date,
    effective_end_date,
    is_current
)
SELECT
    new_risk_history_id,
    customer_id,
    new_credit_score_band,
    new_credit_score,
    new_risk_segment,
    income_band,
    employment_status,
    new_effective_start_date,
    DATE '2099-12-31',
    TRUE
FROM numbered_inserts;

-- 6. Validate that each staged customer has exactly one current record.
SELECT
    customer_id,
    COUNT(*) FILTER (WHERE is_current = TRUE) AS current_record_count,
    MIN(effective_start_date) AS first_effective_start_date,
    MAX(effective_start_date) AS latest_effective_start_date
FROM banking.fact_customer_risk_history
WHERE customer_id IN (SELECT customer_id FROM tmp_customer_risk_changes)
GROUP BY customer_id
ORDER BY customer_id;

-- Demonstration only: roll back so the sample dataset remains unchanged.
ROLLBACK;

\echo 'SCD Type 2 demonstration complete. Changes were rolled back intentionally.'
