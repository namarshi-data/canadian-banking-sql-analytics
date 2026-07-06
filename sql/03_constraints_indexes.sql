\echo 'Adding primary keys, uniqueness, checks, foreign keys, and indexes...'

SET search_path TO banking, public;

-- Idempotency reset
-- -----------------
-- The project build should be safe to run more than once in the same database.
-- PostgreSQL does not support ALTER TABLE ... ADD CONSTRAINT IF NOT EXISTS, so
-- existing portfolio constraints are dropped first and recreated below.
ALTER TABLE banking.fact_service_requests DROP CONSTRAINT IF EXISTS fk_service_customer CASCADE;
ALTER TABLE banking.fact_campaign_contacts DROP CONSTRAINT IF EXISTS fk_contacts_customer CASCADE;
ALTER TABLE banking.fact_campaign_contacts DROP CONSTRAINT IF EXISTS fk_contacts_campaign CASCADE;
ALTER TABLE banking.fact_branch_monthly_targets DROP CONSTRAINT IF EXISTS fk_targets_branch CASCADE;
ALTER TABLE banking.fact_fraud_alerts DROP CONSTRAINT IF EXISTS fk_fraud_transaction CASCADE;
ALTER TABLE banking.fact_loan_payments DROP CONSTRAINT IF EXISTS fk_payments_loan CASCADE;
ALTER TABLE banking.fact_loans DROP CONSTRAINT IF EXISTS fk_loans_account CASCADE;
ALTER TABLE banking.fact_customer_risk_history DROP CONSTRAINT IF EXISTS fk_risk_customer CASCADE;
ALTER TABLE banking.fact_card_statements DROP CONSTRAINT IF EXISTS fk_card_account CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS fk_transactions_date CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS fk_transactions_product CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS fk_transactions_branch CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS fk_transactions_institution CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS fk_transactions_customer CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS fk_transactions_account CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS fk_balances_date CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS fk_balances_product CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS fk_balances_branch CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS fk_balances_institution CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS fk_balances_customer CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS fk_balances_account CASCADE;
ALTER TABLE banking.bridge_account_customers DROP CONSTRAINT IF EXISTS fk_bridge_customer CASCADE;
ALTER TABLE banking.bridge_account_customers DROP CONSTRAINT IF EXISTS fk_bridge_account CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS fk_accounts_product CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS fk_accounts_branch CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS fk_accounts_institution CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS fk_accounts_customer CASCADE;
ALTER TABLE banking.dim_branches DROP CONSTRAINT IF EXISTS fk_branches_geo CASCADE;
ALTER TABLE banking.dim_branches DROP CONSTRAINT IF EXISTS fk_branches_institution CASCADE;
ALTER TABLE banking.dim_customers DROP CONSTRAINT IF EXISTS fk_customers_geo CASCADE;

ALTER TABLE banking.fact_service_requests DROP CONSTRAINT IF EXISTS ck_service_resolution_nonnegative CASCADE;
ALTER TABLE banking.fact_campaign_contacts DROP CONSTRAINT IF EXISTS ck_campaign_revenue_nonnegative CASCADE;
ALTER TABLE banking.fact_fx_rates DROP CONSTRAINT IF EXISTS ck_fx_rate_positive CASCADE;
ALTER TABLE banking.fact_fraud_alerts DROP CONSTRAINT IF EXISTS ck_fraud_loss CASCADE;
ALTER TABLE banking.fact_loan_payments DROP CONSTRAINT IF EXISTS ck_payments_late CASCADE;
ALTER TABLE banking.fact_loans DROP CONSTRAINT IF EXISTS ck_loans_dates CASCADE;
ALTER TABLE banking.fact_customer_risk_history DROP CONSTRAINT IF EXISTS ck_risk_score_range CASCADE;
ALTER TABLE banking.fact_card_statements DROP CONSTRAINT IF EXISTS ck_card_utilization CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS ck_transactions_status CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS ck_balances_currency CASCADE;
ALTER TABLE banking.bridge_account_customers DROP CONSTRAINT IF EXISTS ck_bridge_ownership_percent CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS ck_fact_accounts_dates CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS ck_fact_accounts_status CASCADE;
ALTER TABLE banking.dim_products DROP CONSTRAINT IF EXISTS ck_dim_products_currency CASCADE;

ALTER TABLE banking.fact_service_requests DROP CONSTRAINT IF EXISTS uq_fact_service_requests_number CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS uq_fact_transactions_reference CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS uq_fact_accounts_number CASCADE;
ALTER TABLE banking.dim_branches DROP CONSTRAINT IF EXISTS uq_dim_branches_code CASCADE;
ALTER TABLE banking.dim_customers DROP CONSTRAINT IF EXISTS uq_dim_customers_number CASCADE;
ALTER TABLE banking.dim_products DROP CONSTRAINT IF EXISTS uq_dim_products_code CASCADE;
ALTER TABLE banking.dim_institutions DROP CONSTRAINT IF EXISTS uq_dim_institutions_code CASCADE;

ALTER TABLE banking.fact_service_requests DROP CONSTRAINT IF EXISTS pk_fact_service_requests CASCADE;
ALTER TABLE banking.fact_campaign_contacts DROP CONSTRAINT IF EXISTS pk_fact_campaign_contacts CASCADE;
ALTER TABLE banking.fact_branch_monthly_targets DROP CONSTRAINT IF EXISTS pk_fact_branch_monthly_targets CASCADE;
ALTER TABLE banking.fact_fx_rates DROP CONSTRAINT IF EXISTS pk_fact_fx_rates CASCADE;
ALTER TABLE banking.fact_fraud_alerts DROP CONSTRAINT IF EXISTS pk_fact_fraud_alerts CASCADE;
ALTER TABLE banking.fact_loan_payments DROP CONSTRAINT IF EXISTS pk_fact_loan_payments CASCADE;
ALTER TABLE banking.fact_loans DROP CONSTRAINT IF EXISTS pk_fact_loans CASCADE;
ALTER TABLE banking.fact_customer_risk_history DROP CONSTRAINT IF EXISTS pk_fact_customer_risk_history CASCADE;
ALTER TABLE banking.fact_card_statements DROP CONSTRAINT IF EXISTS pk_fact_card_statements CASCADE;
ALTER TABLE banking.fact_transactions DROP CONSTRAINT IF EXISTS pk_fact_transactions CASCADE;
ALTER TABLE banking.fact_monthly_account_balances DROP CONSTRAINT IF EXISTS pk_fact_monthly_account_balances CASCADE;
ALTER TABLE banking.bridge_account_customers DROP CONSTRAINT IF EXISTS pk_bridge_account_customers CASCADE;
ALTER TABLE banking.fact_accounts DROP CONSTRAINT IF EXISTS pk_fact_accounts CASCADE;
ALTER TABLE banking.dim_branches DROP CONSTRAINT IF EXISTS pk_dim_branches CASCADE;
ALTER TABLE banking.dim_customers DROP CONSTRAINT IF EXISTS pk_dim_customers CASCADE;
ALTER TABLE banking.dim_campaigns DROP CONSTRAINT IF EXISTS pk_dim_campaigns CASCADE;
ALTER TABLE banking.dim_products DROP CONSTRAINT IF EXISTS pk_dim_products CASCADE;
ALTER TABLE banking.dim_interest_rates DROP CONSTRAINT IF EXISTS pk_dim_interest_rates CASCADE;
ALTER TABLE banking.dim_tax_rates DROP CONSTRAINT IF EXISTS pk_dim_tax_rates CASCADE;
ALTER TABLE banking.dim_date DROP CONSTRAINT IF EXISTS pk_dim_date CASCADE;
ALTER TABLE banking.dim_geography DROP CONSTRAINT IF EXISTS pk_dim_geography CASCADE;
ALTER TABLE banking.dim_institutions DROP CONSTRAINT IF EXISTS pk_dim_institutions CASCADE;

-- Primary keys
ALTER TABLE banking.dim_institutions ADD CONSTRAINT pk_dim_institutions PRIMARY KEY (institution_id);
ALTER TABLE banking.dim_geography ADD CONSTRAINT pk_dim_geography PRIMARY KEY (geo_id);
ALTER TABLE banking.dim_date ADD CONSTRAINT pk_dim_date PRIMARY KEY (date_key);
ALTER TABLE banking.dim_tax_rates ADD CONSTRAINT pk_dim_tax_rates PRIMARY KEY (tax_rate_id);
ALTER TABLE banking.dim_interest_rates ADD CONSTRAINT pk_dim_interest_rates PRIMARY KEY (rate_id);
ALTER TABLE banking.dim_products ADD CONSTRAINT pk_dim_products PRIMARY KEY (product_id);
ALTER TABLE banking.dim_campaigns ADD CONSTRAINT pk_dim_campaigns PRIMARY KEY (campaign_id);
ALTER TABLE banking.dim_customers ADD CONSTRAINT pk_dim_customers PRIMARY KEY (customer_id);
ALTER TABLE banking.dim_branches ADD CONSTRAINT pk_dim_branches PRIMARY KEY (branch_id);
ALTER TABLE banking.fact_accounts ADD CONSTRAINT pk_fact_accounts PRIMARY KEY (account_id);
ALTER TABLE banking.bridge_account_customers ADD CONSTRAINT pk_bridge_account_customers PRIMARY KEY (account_customer_id);
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT pk_fact_monthly_account_balances PRIMARY KEY (balance_id);
ALTER TABLE banking.fact_transactions ADD CONSTRAINT pk_fact_transactions PRIMARY KEY (transaction_id);
ALTER TABLE banking.fact_card_statements ADD CONSTRAINT pk_fact_card_statements PRIMARY KEY (statement_id);
ALTER TABLE banking.fact_customer_risk_history ADD CONSTRAINT pk_fact_customer_risk_history PRIMARY KEY (risk_history_id);
ALTER TABLE banking.fact_loans ADD CONSTRAINT pk_fact_loans PRIMARY KEY (loan_id);
ALTER TABLE banking.fact_loan_payments ADD CONSTRAINT pk_fact_loan_payments PRIMARY KEY (loan_payment_id);
ALTER TABLE banking.fact_fraud_alerts ADD CONSTRAINT pk_fact_fraud_alerts PRIMARY KEY (fraud_alert_id);
ALTER TABLE banking.fact_fx_rates ADD CONSTRAINT pk_fact_fx_rates PRIMARY KEY (fx_rate_id);
ALTER TABLE banking.fact_branch_monthly_targets ADD CONSTRAINT pk_fact_branch_monthly_targets PRIMARY KEY (target_id);
ALTER TABLE banking.fact_campaign_contacts ADD CONSTRAINT pk_fact_campaign_contacts PRIMARY KEY (contact_id);
ALTER TABLE banking.fact_service_requests ADD CONSTRAINT pk_fact_service_requests PRIMARY KEY (service_request_id);

-- Business key uniqueness
ALTER TABLE banking.dim_institutions ADD CONSTRAINT uq_dim_institutions_code UNIQUE (institution_code);
ALTER TABLE banking.dim_products ADD CONSTRAINT uq_dim_products_code UNIQUE (product_code);
ALTER TABLE banking.dim_customers ADD CONSTRAINT uq_dim_customers_number UNIQUE (customer_number);
ALTER TABLE banking.dim_branches ADD CONSTRAINT uq_dim_branches_code UNIQUE (branch_code);
ALTER TABLE banking.fact_accounts ADD CONSTRAINT uq_fact_accounts_number UNIQUE (account_number);
ALTER TABLE banking.fact_transactions ADD CONSTRAINT uq_fact_transactions_reference UNIQUE (transaction_reference);
ALTER TABLE banking.fact_service_requests ADD CONSTRAINT uq_fact_service_requests_number UNIQUE (service_request_number);

-- Check constraints
ALTER TABLE banking.dim_products ADD CONSTRAINT ck_dim_products_currency CHECK (currency IN ('CAD','USD'));
ALTER TABLE banking.fact_accounts ADD CONSTRAINT ck_fact_accounts_status CHECK (account_status IN ('Open', 'Dormant', 'Closed', 'Frozen'));
ALTER TABLE banking.fact_accounts ADD CONSTRAINT ck_fact_accounts_dates CHECK (close_date IS NULL OR close_date >= open_date);
ALTER TABLE banking.bridge_account_customers ADD CONSTRAINT ck_bridge_ownership_percent CHECK (ownership_percent > 0 AND ownership_percent <= 1);
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT ck_balances_currency CHECK (currency IN ('CAD','USD'));
ALTER TABLE banking.fact_transactions ADD CONSTRAINT ck_transactions_status CHECK (transaction_status IN ('Completed','Failed','Pending','Reversed'));
ALTER TABLE banking.fact_card_statements ADD CONSTRAINT ck_card_utilization CHECK (utilization_rate >= 0 AND utilization_rate <= 1.25);
ALTER TABLE banking.fact_customer_risk_history ADD CONSTRAINT ck_risk_score_range CHECK (credit_score IS NULL OR credit_score BETWEEN 300 AND 900);
ALTER TABLE banking.fact_loans ADD CONSTRAINT ck_loans_dates CHECK (close_date IS NULL OR close_date >= origination_date);
ALTER TABLE banking.fact_loan_payments ADD CONSTRAINT ck_payments_late CHECK (days_late >= 0);
ALTER TABLE banking.fact_fraud_alerts ADD CONSTRAINT ck_fraud_loss CHECK (estimated_loss_amount >= 0);
ALTER TABLE banking.fact_fx_rates ADD CONSTRAINT ck_fx_rate_positive CHECK (exchange_rate > 0);
ALTER TABLE banking.fact_campaign_contacts ADD CONSTRAINT ck_campaign_revenue_nonnegative CHECK (estimated_revenue >= 0);
ALTER TABLE banking.fact_service_requests ADD CONSTRAINT ck_service_resolution_nonnegative CHECK (resolution_hours >= 0);

-- Foreign keys are added NOT VALID so the database can load real-world imperfect data and then report exceptions.
ALTER TABLE banking.dim_customers ADD CONSTRAINT fk_customers_geo FOREIGN KEY (geo_id) REFERENCES banking.dim_geography(geo_id) NOT VALID;
ALTER TABLE banking.dim_branches ADD CONSTRAINT fk_branches_institution FOREIGN KEY (institution_id) REFERENCES banking.dim_institutions(institution_id) NOT VALID;
ALTER TABLE banking.dim_branches ADD CONSTRAINT fk_branches_geo FOREIGN KEY (geo_id) REFERENCES banking.dim_geography(geo_id) NOT VALID;
ALTER TABLE banking.fact_accounts ADD CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;
ALTER TABLE banking.fact_accounts ADD CONSTRAINT fk_accounts_institution FOREIGN KEY (institution_id) REFERENCES banking.dim_institutions(institution_id) NOT VALID;
ALTER TABLE banking.fact_accounts ADD CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) REFERENCES banking.dim_branches(branch_id) NOT VALID;
ALTER TABLE banking.fact_accounts ADD CONSTRAINT fk_accounts_product FOREIGN KEY (product_id) REFERENCES banking.dim_products(product_id) NOT VALID;
ALTER TABLE banking.bridge_account_customers ADD CONSTRAINT fk_bridge_account FOREIGN KEY (account_id) REFERENCES banking.fact_accounts(account_id) NOT VALID;
ALTER TABLE banking.bridge_account_customers ADD CONSTRAINT fk_bridge_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT fk_balances_account FOREIGN KEY (account_id) REFERENCES banking.fact_accounts(account_id) NOT VALID;
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT fk_balances_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT fk_balances_institution FOREIGN KEY (institution_id) REFERENCES banking.dim_institutions(institution_id) NOT VALID;
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT fk_balances_branch FOREIGN KEY (branch_id) REFERENCES banking.dim_branches(branch_id) NOT VALID;
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT fk_balances_product FOREIGN KEY (product_id) REFERENCES banking.dim_products(product_id) NOT VALID;
ALTER TABLE banking.fact_monthly_account_balances ADD CONSTRAINT fk_balances_date FOREIGN KEY (date_key) REFERENCES banking.dim_date(date_key) NOT VALID;
ALTER TABLE banking.fact_transactions ADD CONSTRAINT fk_transactions_account FOREIGN KEY (account_id) REFERENCES banking.fact_accounts(account_id) NOT VALID;
ALTER TABLE banking.fact_transactions ADD CONSTRAINT fk_transactions_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;
ALTER TABLE banking.fact_transactions ADD CONSTRAINT fk_transactions_institution FOREIGN KEY (institution_id) REFERENCES banking.dim_institutions(institution_id) NOT VALID;
ALTER TABLE banking.fact_transactions ADD CONSTRAINT fk_transactions_branch FOREIGN KEY (branch_id) REFERENCES banking.dim_branches(branch_id) NOT VALID;
ALTER TABLE banking.fact_transactions ADD CONSTRAINT fk_transactions_product FOREIGN KEY (product_id) REFERENCES banking.dim_products(product_id) NOT VALID;
ALTER TABLE banking.fact_transactions ADD CONSTRAINT fk_transactions_date FOREIGN KEY (date_key) REFERENCES banking.dim_date(date_key) NOT VALID;
ALTER TABLE banking.fact_card_statements ADD CONSTRAINT fk_card_account FOREIGN KEY (account_id) REFERENCES banking.fact_accounts(account_id) NOT VALID;
ALTER TABLE banking.fact_customer_risk_history ADD CONSTRAINT fk_risk_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;
ALTER TABLE banking.fact_loans ADD CONSTRAINT fk_loans_account FOREIGN KEY (account_id) REFERENCES banking.fact_accounts(account_id) NOT VALID;
ALTER TABLE banking.fact_loan_payments ADD CONSTRAINT fk_payments_loan FOREIGN KEY (loan_id) REFERENCES banking.fact_loans(loan_id) NOT VALID;
ALTER TABLE banking.fact_fraud_alerts ADD CONSTRAINT fk_fraud_transaction FOREIGN KEY (transaction_id) REFERENCES banking.fact_transactions(transaction_id) NOT VALID;
ALTER TABLE banking.fact_branch_monthly_targets ADD CONSTRAINT fk_targets_branch FOREIGN KEY (branch_id) REFERENCES banking.dim_branches(branch_id) NOT VALID;
ALTER TABLE banking.fact_campaign_contacts ADD CONSTRAINT fk_contacts_campaign FOREIGN KEY (campaign_id) REFERENCES banking.dim_campaigns(campaign_id) NOT VALID;
-- Nullable FK: campaign contacts can be prospects, but populated customer_id values must still reference a known customer.
ALTER TABLE banking.fact_campaign_contacts ADD CONSTRAINT fk_contacts_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;
ALTER TABLE banking.fact_service_requests ADD CONSTRAINT fk_service_customer FOREIGN KEY (customer_id) REFERENCES banking.dim_customers(customer_id) NOT VALID;

-- Performance indexes for common analyst access patterns
CREATE INDEX IF NOT EXISTS idx_customers_geo ON banking.dim_customers (geo_id, province, city);
CREATE INDEX IF NOT EXISTS idx_accounts_customer_product ON banking.fact_accounts (customer_id, product_id, account_status);
CREATE INDEX IF NOT EXISTS idx_accounts_institution_branch ON banking.fact_accounts (institution_id, branch_id);
CREATE INDEX IF NOT EXISTS idx_balances_month_inst_product ON banking.fact_monthly_account_balances (month_end_date, institution_id, product_id);
CREATE INDEX IF NOT EXISTS idx_balances_customer_month ON banking.fact_monthly_account_balances (customer_id, month_end_date);
CREATE INDEX IF NOT EXISTS idx_transactions_date_inst_channel ON banking.fact_transactions (transaction_date, institution_id, channel);
CREATE INDEX IF NOT EXISTS idx_transactions_account_date ON banking.fact_transactions (account_id, transaction_date);
CREATE INDEX IF NOT EXISTS idx_card_customer_statement ON banking.fact_card_statements (customer_id, statement_date);
CREATE INDEX IF NOT EXISTS idx_risk_customer_current ON banking.fact_customer_risk_history (customer_id, is_current);
CREATE INDEX IF NOT EXISTS idx_loans_customer_status ON banking.fact_loans (customer_id, loan_status);
CREATE INDEX IF NOT EXISTS idx_payments_loan_due ON banking.fact_loan_payments (loan_id, due_date);
CREATE INDEX IF NOT EXISTS idx_fraud_alert_date_severity ON banking.fact_fraud_alerts (alert_date, severity, confirmed_fraud_flag);
CREATE INDEX IF NOT EXISTS idx_service_branch_created ON banking.fact_service_requests (branch_id, created_date, priority);
CREATE INDEX IF NOT EXISTS idx_campaign_contacts_campaign_date ON banking.fact_campaign_contacts (campaign_id, contact_date, test_group);

\echo 'Constraints and indexes complete.'
