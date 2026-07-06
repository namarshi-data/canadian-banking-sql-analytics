\echo 'Creating schemas for Canadian banking SQL analytics project...'

CREATE SCHEMA IF NOT EXISTS banking;
CREATE SCHEMA IF NOT EXISTS mart;
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA banking IS 'Typed source tables loaded from synthetic Canadian banking CSV files.';
COMMENT ON SCHEMA mart IS 'Reusable analytics views and materialized views for analyst reporting.';
COMMENT ON SCHEMA audit IS 'Data quality, reconciliation, and operational database helper objects.';

SET search_path TO banking, public;
