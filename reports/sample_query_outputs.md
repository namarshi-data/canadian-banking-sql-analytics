# Sample Query Outputs

This file documents expected output themes after running the SQL scripts. Exact formatting depends on the SQL client.

## Row-count reconciliation

Expected result: 22 tables checked, 22 passed, 0 failed. `dim_date` uses a minimum row-count rule because it is enriched during load; all core fact and dimension source tables reconcile exactly.

## Data-quality checks

Expected outcome:

- Critical checks should return zero exceptions after the reproducible load process.
- Customer postal-code gaps, high card utilization, late loan payments, prospect campaign contacts, and no-score risk records are documented as `Review` or `Monitor` findings instead of hidden data issues.
- Transaction date keys and service SLA breach flags are standardized during load, so time-series and SLA reporting use consistent business definitions.

## Analyst case studies

Recommended review queries:

1. Case 01: monthly institution balance trend with MoM growth.
2. Case 03: branch target misses.
3. Case 04: customer 360 review queue.
4. Case 07: fraud false-positive and confirmed-loss analysis.
5. Case 15: data-quality scorecard.


## Assertion test result

Expected result: all 9 assertion-style tests should return `PASS`, including transaction date coverage, SLA flag alignment, valid populated campaign customer references, valid credit-score ranges, and `No Score` labeling for null credit-score records.
