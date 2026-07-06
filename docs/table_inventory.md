# Table Inventory

Source CSV rows: **514,632**

| Table | Rows | Columns |
|---|---:|---:|
| `bridge_account_customers` | 15,545 | 5 |
| `dim_branches` | 226 | 11 |
| `dim_campaigns` | 6 | 8 |
| `dim_customers` | 7,000 | 18 |
| `dim_date` | 1,096 | 11 |
| `dim_geography` | 27 | 7 |
| `dim_institutions` | 6 | 10 |
| `dim_interest_rates` | 7 | 6 |
| `dim_products` | 15 | 10 |
| `dim_tax_rates` | 14 | 6 |
| `fact_accounts` | 14,362 | 13 |
| `fact_branch_monthly_targets` | 5,424 | 9 |
| `fact_campaign_contacts` | 10,800 | 10 |
| `fact_card_statements` | 43,470 | 16 |
| `fact_customer_risk_history` | 8,419 | 10 |
| `fact_fraud_alerts` | 1,800 | 12 |
| `fact_fx_rates` | 2,192 | 6 |
| `fact_loan_payments` | 29,246 | 14 |
| `fact_loans` | 1,702 | 13 |
| `fact_monthly_account_balances` | 296,775 | 12 |
| `fact_service_requests` | 6,500 | 14 |
| `fact_transactions` | 70,000 | 15 |

## Post-load note

`dim_date` contains **1,096** rows in the source CSV and **1,099** rows after the PostgreSQL load. The additional three dates are inserted from valid transaction dates so `fact_transactions.date_key` resolves cleanly to the conformed date dimension. Reconciliation tests therefore use a `MINIMUM` rule for `dim_date` and exact source row counts for all other tables.
