-- Advanced SQL: CTEs and window functions

-- Month-over-month institution balance trend.
WITH monthly AS (
    SELECT month_end_date, institution_code, SUM(ending_balance) AS ending_balance
    FROM mart.v_monthly_institution_kpis
    GROUP BY month_end_date, institution_code
)
SELECT
    month_end_date,
    institution_code,
    ending_balance,
    LAG(ending_balance) OVER (PARTITION BY institution_code ORDER BY month_end_date) AS previous_month_balance,
    ending_balance - LAG(ending_balance) OVER (PARTITION BY institution_code ORDER BY month_end_date) AS mom_balance_change,
    RANK() OVER (PARTITION BY month_end_date ORDER BY ending_balance DESC) AS balance_rank_in_month
FROM monthly
ORDER BY month_end_date DESC, balance_rank_in_month;

-- Top 5 branches per institution by latest deposit balance.
WITH latest_month AS (
    SELECT MAX(month_end_date) AS month_end_date FROM banking.fact_monthly_account_balances
), branch_balances AS (
    SELECT
        i.institution_code,
        br.branch_code,
        br.branch_name,
        br.province,
        SUM(b.ending_balance) AS deposit_balance
    FROM banking.fact_monthly_account_balances b
    JOIN latest_month lm ON lm.month_end_date = b.month_end_date
    JOIN banking.dim_products p ON p.product_id = b.product_id AND p.product_family = 'Deposit'
    JOIN banking.dim_branches br ON br.branch_id = b.branch_id
    JOIN banking.dim_institutions i ON i.institution_id = b.institution_id
    GROUP BY i.institution_code, br.branch_code, br.branch_name, br.province
), ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY institution_code ORDER BY deposit_balance DESC) AS rn
    FROM branch_balances
)
SELECT * FROM ranked WHERE rn <= 5 ORDER BY institution_code, rn;
