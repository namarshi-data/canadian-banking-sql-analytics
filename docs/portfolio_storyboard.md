# Portfolio Storyboard

## 1. Business problem

Canadian banks need trusted analytics across branch performance, deposits, credit risk, fraud alerts, service SLAs, and customer growth. Analysts must convert raw operational tables into validated KPIs and actionable recommendations.

## 2. Data model

The project uses dimensions for customers, branches, institutions, products, geography, date, campaigns, tax, and rates. Facts represent accounts, monthly balances, transactions, card statements, loans, loan payments, fraud alerts, campaigns, service requests, and branch targets.

## 3. SQL build

The repository creates schemas, stages and standardizes CSV data, enriches `dim_date` for valid transaction dates, recalculates SLA breach flags from a documented business rule, adds constraints and indexes, validates quality, creates analytics views, and refreshes materialized views.

## 4. Analysis flow

- Start with row-count reconciliation: 22 checked, 22 passed, 0 failed.
- Validate assertion-style data-quality controls: 9 passed, 0 failed.
- Review documented business-monitoring items such as postal-code gaps, no-score customers, high utilization, and late payments.
- Review monthly institution KPIs.
- Identify branch target misses.
- Build customer 360 and high-risk queues.
- Analyze fraud and service operations.
- Review campaign performance.
- Communicate recommendations.

## 5. Recruiter message

This project shows I can handle a realistic analytics workflow: database modelling, business logic, quality controls, performance-aware SQL, and stakeholder-ready outputs.
