# Executive Insights Sample

These sample insights were generated from the synthetic CSV dataset and are included to show how SQL results can be translated into business language.

## Portfolio scale

- The source CSV dataset contains 514,632 rows across 22 tables; the PostgreSQL load enriches `dim_date` by three rows to maintain transaction date-key coverage.
- Core reporting areas include customers, accounts, monthly balances, transactions, cards, loans, loan payments, fraud alerts, branch targets, campaigns, service requests, FX rates, tax rates, and geography.

## Latest balance snapshot

- Latest balance month in the dataset: **2025-12-31**.
- Total latest ending balance: **$361.38M**.
- Latest-month fee amount: **$95.50K**.
- Latest-month interest amount: **$1.71M**.

## Institution balance ranking at latest month

| Institution | Latest ending balance |
|---|---:|
| RBC | $74.35M |
| TD | $70.11M |
| CIBC | $62.87M |
| BMO | $61.54M |
| BNS | $61.06M |
| NBC | $31.45M |

## Risk and operations signals

- Loan-payment late rate: approximately **11.2%** of loan payment records have at least one late day.
- Card statement records with days past due greater than zero: approximately **14.2%**.
- Card statements with utilization above 80%: approximately **50.1%**.
- Service request breach rates are around 29.6% to 33.6% depending on priority in the synthetic data.
- Fraud alerts include both confirmed fraud and false positives, creating an opportunity to analyze alert quality and operational workload.

## Data quality notes

- Transaction date keys are standardized during load, and `dim_date` is extended for valid out-of-range transaction dates. The final control result has zero missing transaction date keys.
- Service SLA breach flags are recalculated from `resolution_hours > sla_target_hours`, resulting in zero SLA flag mismatches.
- Postal-code blanks exist for a small number of customers and are handled as a data-quality monitoring item rather than a critical failure.
- Reconciliation checks pass for all 22 tables, and assertion-style data-quality checks pass for all 9 core controls.

## Recommended business actions

1. Use `mart.v_branch_target_attainment` to identify branches missing multiple KPIs in the same month.
2. Use `mart.mv_high_risk_customer_snapshot` to prioritize manual risk review queues.
3. Use `mart.v_fraud_operations` to reduce false-positive pressure while preserving confirmed fraud capture.
4. Use `mart.v_service_sla` to identify request types and channels causing service delays.
5. Use `mart.v_campaign_performance` to compare targeted vs control conversion performance.
