-- Core SQL questions: joins, aggregation, filters, CASE, HAVING

-- 1. How many active customers are in each province?
SELECT province, COUNT(*) AS active_customers
FROM banking.dim_customers
WHERE is_active = TRUE
GROUP BY province
ORDER BY active_customers DESC;

-- 2. Which product families have the most open accounts?
SELECT p.product_family, p.product_category, COUNT(*) AS open_accounts
FROM banking.fact_accounts a
JOIN banking.dim_products p ON p.product_id = a.product_id
WHERE a.account_status = 'Open'
GROUP BY p.product_family, p.product_category
ORDER BY open_accounts DESC;

-- 3. Which channels drive the largest completed transaction volume?
SELECT channel, COUNT(*) AS completed_transactions, SUM(amount) AS net_amount
FROM banking.fact_transactions
WHERE transaction_status = 'Completed'
GROUP BY channel
HAVING COUNT(*) >= 100
ORDER BY completed_transactions DESC;
