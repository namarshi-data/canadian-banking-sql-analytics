# Entity Relationship Diagram

```mermaid
erDiagram
    dim_institutions ||--o{ dim_branches : has
    dim_geography ||--o{ dim_branches : locates
    dim_geography ||--o{ dim_customers : locates
    dim_customers ||--o{ fact_accounts : owns
    dim_institutions ||--o{ fact_accounts : manages
    dim_branches ||--o{ fact_accounts : opens
    dim_products ||--o{ fact_accounts : classifies
    fact_accounts ||--o{ bridge_account_customers : has_joint_owners
    dim_customers ||--o{ bridge_account_customers : participates
    fact_accounts ||--o{ fact_monthly_account_balances : reports
    dim_date ||--o{ fact_monthly_account_balances : dates
    fact_accounts ||--o{ fact_transactions : posts
    dim_date ||--o{ fact_transactions : dates
    fact_accounts ||--o{ fact_card_statements : bills
    dim_customers ||--o{ fact_customer_risk_history : has
    fact_accounts ||--o{ fact_loans : funds
    fact_loans ||--o{ fact_loan_payments : receives
    fact_transactions ||--o{ fact_fraud_alerts : triggers
    dim_campaigns ||--o{ fact_campaign_contacts : sends
    dim_customers ||--o{ fact_campaign_contacts : receives_when_customer_linked
    dim_branches ||--o{ fact_branch_monthly_targets : targets
    fact_accounts ||--o{ fact_service_requests : supports
```

## Modelling notes

- The model uses dimensions, facts, and a bridge table to support many-to-many account ownership.
- `fact_monthly_account_balances` is the main monthly performance fact.
- `fact_transactions` is the transaction-level activity table.
- `fact_customer_risk_history` behaves like a slowly changing history table with current and historical records; `credit_score` is nullable for new-to-credit, thin-file, or unscoreable customers.
- `fact_campaign_contacts.customer_id` is optional because campaign activity can include prospects or anonymous/pre-acquisition leads; populated values can still be validated against `dim_customers`.
- Marts in the `mart` schema are built on top of these typed source tables.
