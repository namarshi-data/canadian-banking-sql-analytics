# Data Dictionary

This dictionary summarizes the source CSV tables used in the PostgreSQL project. Data is synthetic and portfolio-safe.

## `bridge_account_customers`

Rows: **15,545**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `account_customer_id` | `int64` | Account customer id. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `ownership_role` | `object` | Ownership role. |
| `ownership_percent` | `float64` | Ownership percent. |

## `dim_branches`

Rows: **226**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `branch_id` | `int64` | Surrogate branch key. |
| `branch_code` | `object` | Branch code. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `geo_id` | `int64` | Geo id. |
| `branch_name` | `object` | Branch name. |
| `city` | `object` | City. |
| `province` | `object` | Province. |
| `postal_code` | `object` | Postal code. |
| `branch_type` | `object` | Branch type. |
| `open_date` | `object` | Open date. |
| `is_active` | `bool` | Is active. |

## `dim_campaigns`

Rows: **6**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `campaign_id` | `int64` | Campaign id. |
| `campaign_name` | `object` | Campaign name. |
| `campaign_type` | `object` | Campaign type. |
| `target_product_family` | `object` | Target product family. |
| `start_date` | `object` | Start date. |
| `end_date` | `object` | End date. |
| `budget_amount` | `int64` | Budget amount. |
| `campaign_description` | `object` | Campaign description. |

## `dim_customers`

Rows: **7,000**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `customer_number` | `object` | Customer number. |
| `first_name` | `object` | First name. |
| `last_name` | `object` | Last name. |
| `email` | `object` | Email. |
| `phone_last4` | `int64` | Phone last4. |
| `birth_year` | `int64` | Birth year. |
| `age_2025` | `int64` | Age 2025. |
| `customer_segment` | `object` | Customer segment. |
| `income_band` | `object` | Income band. |
| `employment_status` | `object` | Employment status. |
| `geo_id` | `int64` | Geo id. |
| `province` | `object` | Province. |
| `city` | `object` | City. |
| `postal_code` | `object` | Postal code. |
| `signup_date` | `object` | Signup date. |
| `onboarding_channel` | `object` | Onboarding channel. |
| `is_active` | `bool` | Is active. |

## `dim_date`

Rows: **1,096 source rows / 1,099 post-load rows**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `date_key` | `int64` | Calendar date key in YYYYMMDD format. |
| `calendar_date` | `object` | Calendar date. |
| `year` | `int64` | Year. |
| `quarter` | `int64` | Quarter. |
| `month` | `int64` | Month. |
| `month_name` | `object` | Month name. |
| `week_of_year` | `int64` | Week of year. |
| `day_of_week` | `int64` | Day of week. |
| `is_weekend` | `bool` | Is weekend. |
| `month_start_date` | `object` | Month start date. |
| `month_end_date` | `object` | Month-end reporting date. |

**Post-load enrichment rule:** `dim_date` is extended during PostgreSQL loading when valid transaction dates fall outside the base calendar. This preserves referential integrity for transaction reporting while retaining source-row reconciliation transparency.

## `dim_geography`

Rows: **27**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `geo_id` | `int64` | Geo id. |
| `province` | `object` | Province. |
| `province_name` | `object` | Province name. |
| `city` | `object` | City. |
| `postal_prefix` | `object` | Postal prefix. |
| `metro_area` | `object` | Metro area. |
| `region` | `object` | Region. |

## `dim_institutions`

Rows: **6**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `institution_code` | `object` | Institution code. |
| `institution_name` | `object` | Institution name. |
| `institution_group` | `object` | Institution group. |
| `institution_type` | `object` | Institution type. |
| `is_big5` | `bool` | Is big5. |
| `is_dsib` | `bool` | Is dsib. |
| `is_active` | `bool` | Is active. |
| `headquarters_city` | `object` | Headquarters city. |
| `headquarters_province` | `object` | Headquarters province. |

## `dim_interest_rates`

Rows: **7**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `rate_id` | `int64` | Rate id. |
| `rate_code` | `object` | Rate code. |
| `rate_name` | `object` | Rate name. |
| `annual_rate` | `float64` | Annual rate. |
| `effective_start_date` | `object` | Effective start date. |
| `effective_end_date` | `object` | Effective end date. |

## `dim_products`

Rows: **15**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `product_id` | `int64` | Surrogate product key. |
| `product_code` | `object` | Product code. |
| `product_name` | `object` | Product name. |
| `product_family` | `object` | Product family. |
| `product_category` | `object` | Product category. |
| `currency` | `object` | Currency. |
| `monthly_fee` | `float64` | Monthly fee. |
| `minimum_balance` | `float64` | Minimum balance. |
| `base_rate` | `float64` | Base rate. |
| `is_credit_product` | `bool` | Is credit product. |

## `dim_tax_rates`

Rows: **14**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `tax_rate_id` | `int64` | Tax rate id. |
| `province` | `object` | Province. |
| `province_name` | `object` | Province name. |
| `total_tax_rate` | `float64` | Total tax rate. |
| `effective_start_date` | `object` | Effective start date. |
| `effective_end_date` | `object` | Effective end date. |

## `fact_accounts`

Rows: **14,362**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `account_id` | `int64` | Surrogate account key. |
| `account_number` | `object` | Account number. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `product_id` | `int64` | Surrogate product key. |
| `open_date` | `object` | Open date. |
| `close_date` | `object` | Close date. |
| `account_status` | `object` | Account status. |
| `currency` | `object` | Currency. |
| `credit_limit` | `float64` | Credit limit. |
| `original_principal` | `float64` | Original principal. |
| `is_joint_account` | `bool` | Is joint account. |

## `fact_branch_monthly_targets`

Rows: **5,424**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `target_id` | `int64` | Target id. |
| `branch_id` | `int64` | Surrogate branch key. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `date_key` | `int64` | Calendar date key in YYYYMMDD format. |
| `month_end_date` | `object` | Month-end reporting date. |
| `deposit_balance_target` | `float64` | Deposit balance target. |
| `loan_originations_target` | `float64` | Loan originations target. |
| `new_accounts_target` | `int64` | New accounts target. |
| `service_sla_target` | `float64` | Service sla target. |

## `fact_campaign_contacts`

Rows: **10,800**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `contact_id` | `int64` | Contact id. |
| `campaign_id` | `int64` | Campaign id. |
| `customer_id` | `float64` | Nullable customer key. Null values represent prospects, anonymous leads, or pre-acquisition marketing outreach retained for campaign-level analysis. |
| `contact_date` | `object` | Contact date. |
| `contact_channel` | `object` | Contact channel. |
| `opened_flag` | `bool` | Opened flag. |
| `clicked_flag` | `bool` | Clicked flag. |
| `converted_flag` | `bool` | Converted flag. |
| `estimated_revenue` | `float64` | Estimated revenue. |
| `test_group` | `object` | Test group. |

**Business-valid null rule:** `customer_id` may be null for prospect or anonymous outreach; non-null customer keys are validated against `dim_customers`.

## `fact_card_statements`

Rows: **43,470**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `statement_id` | `int64` | Statement id. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `date_key` | `int64` | Calendar date key in YYYYMMDD format. |
| `statement_date` | `object` | Statement date. |
| `credit_limit` | `float64` | Credit limit. |
| `statement_balance` | `float64` | Statement balance. |
| `purchase_amount` | `float64` | Purchase amount. |
| `payment_amount` | `float64` | Payment amount. |
| `interest_charged` | `float64` | Interest charged. |
| `fee_charged` | `int64` | Fee charged. |
| `minimum_payment_due` | `float64` | Minimum payment due. |
| `days_past_due` | `int64` | Days past due. |
| `utilization_rate` | `float64` | Utilization rate. |

## `fact_customer_risk_history`

Rows: **8,419**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `risk_history_id` | `int64` | Risk history id. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `credit_score_band` | `object` | Credit score band. |
| `credit_score` | `float64` | Nullable synthetic credit score. Null values represent new-to-credit, thin-file, or unscoreable customers retained under the No Score segment. |
| `risk_segment` | `object` | Customer risk classification in the synthetic dataset. |
| `income_band` | `object` | Income band. |
| `employment_status` | `object` | Employment status. |
| `effective_start_date` | `object` | Effective start date. |
| `effective_end_date` | `object` | Effective end date. |
| `is_current` | `bool` | Is current. |

**Business-valid null rule:** `credit_score` may be null when a customer is not scoreable; populated scores are constrained to the 300-900 range. During load, null-score records are standardized to `credit_score_band = 'No Score'` for consistent segmentation.

## `fact_fraud_alerts`

Rows: **1,800**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `fraud_alert_id` | `int64` | Fraud alert id. |
| `transaction_id` | `int64` | Surrogate transaction key. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `alert_date` | `object` | Alert date. |
| `alert_type` | `object` | Alert type. |
| `severity` | `object` | Severity. |
| `confirmed_fraud_flag` | `bool` | Boolean flag indicating whether a fraud alert was confirmed. |
| `estimated_loss_amount` | `float64` | Estimated loss amount. |
| `resolution_status` | `object` | Resolution status. |

## `fact_fx_rates`

Rows: **2,192**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `fx_rate_id` | `int64` | Fx rate id. |
| `date_key` | `int64` | Calendar date key in YYYYMMDD format. |
| `rate_date` | `object` | Rate date. |
| `from_currency` | `object` | From currency. |
| `to_currency` | `object` | To currency. |
| `exchange_rate` | `float64` | Exchange rate. |

## `fact_loan_payments`

Rows: **29,246**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `loan_payment_id` | `int64` | Loan payment id. |
| `loan_id` | `int64` | Loan id. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `date_key` | `int64` | Calendar date key in YYYYMMDD format. |
| `due_date` | `object` | Due date. |
| `paid_date` | `object` | Paid date. |
| `amount_due` | `float64` | Amount due. |
| `amount_paid` | `float64` | Amount paid. |
| `days_late` | `int64` | Days late. |
| `principal_component` | `float64` | Principal component. |
| `interest_component` | `float64` | Interest component. |
| `payment_status` | `object` | Payment status. |

## `fact_loans`

Rows: **1,702**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `loan_id` | `int64` | Loan id. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `product_id` | `int64` | Surrogate product key. |
| `origination_date` | `object` | Origination date. |
| `close_date` | `object` | Close date. |
| `original_principal` | `float64` | Original principal. |
| `annual_interest_rate` | `float64` | Annual interest rate. |
| `term_months` | `int64` | Term months. |
| `scheduled_monthly_payment` | `float64` | Scheduled monthly payment. |
| `loan_status` | `object` | Loan status. |

## `fact_monthly_account_balances`

Rows: **296,775**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `balance_id` | `int64` | Balance id. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `product_id` | `int64` | Surrogate product key. |
| `date_key` | `int64` | Calendar date key in YYYYMMDD format. |
| `month_end_date` | `object` | Month-end reporting date. |
| `ending_balance` | `float64` | Reported account ending balance at month end. |
| `interest_amount` | `float64` | Interest amount. |
| `fee_amount` | `float64` | Fee amount. |
| `currency` | `object` | Currency. |

## `fact_service_requests`

Rows: **6,500**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `service_request_id` | `int64` | Service request id. |
| `service_request_number` | `object` | Service request number. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `account_id` | `int64` | Surrogate account key. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `created_date` | `object` | Created date. |
| `request_type` | `object` | Request type. |
| `priority` | `object` | Priority. |
| `sla_target_hours` | `int64` | Sla target hours. |
| `resolution_hours` | `float64` | Resolution hours. |
| `sla_breached_flag` | `bool` | Derived SLA flag standardized during load; `TRUE` when `resolution_hours > sla_target_hours`. |
| `request_status` | `object` | Request status. |
| `request_channel` | `object` | Request channel. |

## `fact_transactions`

Rows: **70,000**

| Column | Inferred type | Business meaning |
|---|---:|---|
| `transaction_id` | `int64` | Surrogate transaction key. |
| `transaction_reference` | `object` | Transaction reference. |
| `account_id` | `int64` | Surrogate account key. |
| `customer_id` | `int64` | Surrogate customer key used across customer-related facts. |
| `institution_id` | `int64` | Surrogate institution key for bank or benchmark institution. |
| `branch_id` | `int64` | Surrogate branch key. |
| `product_id` | `int64` | Surrogate product key. |
| `date_key` | `int64` | Calendar date key in YYYYMMDD format; standardized from `transaction_date` during load. |
| `transaction_date` | `object` | Transaction date. |
| `transaction_type` | `object` | Transaction type. |
| `merchant_category` | `object` | Merchant category. |
| `amount` | `float64` | Transaction or financial amount in stated currency. |
| `currency` | `object` | Currency. |
| `channel` | `object` | Channel. |
| `transaction_status` | `object` | Transaction status. |
