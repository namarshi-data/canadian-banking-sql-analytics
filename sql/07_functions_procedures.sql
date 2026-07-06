\echo 'Creating reusable SQL functions and procedures...'

CREATE OR REPLACE FUNCTION mart.risk_tier(credit_score integer)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN credit_score IS NULL THEN 'No Score'
        WHEN credit_score >= 760 THEN 'Prime'
        WHEN credit_score >= 700 THEN 'Near Prime'
        WHEN credit_score >= 640 THEN 'Standard'
        WHEN credit_score >= 580 THEN 'Subprime'
        ELSE 'Deep Subprime'
    END;
$$;

CREATE OR REPLACE FUNCTION mart.month_over_month_pct(current_value numeric, previous_value numeric)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN previous_value IS NULL OR previous_value = 0 THEN NULL
        ELSE ROUND((current_value - previous_value) / previous_value, 6)
    END;
$$;

CREATE OR REPLACE FUNCTION mart.fx_convert_to_cad(p_amount numeric, p_from_currency text, p_rate_dt date)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
    SELECT CASE
        WHEN UPPER(p_from_currency) = 'CAD' THEN p_amount
        ELSE (
            SELECT ROUND(p_amount * fx.exchange_rate, 2)
            FROM banking.fact_fx_rates fx
            WHERE fx.from_currency = UPPER(p_from_currency)
              AND fx.to_currency = 'CAD'
              AND fx.rate_date <= p_rate_dt
            ORDER BY fx.rate_date DESC
            LIMIT 1
        )
    END;
$$;

CREATE OR REPLACE PROCEDURE audit.refresh_reporting_marts()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mart.mv_monthly_customer_product_balances;
    REFRESH MATERIALIZED VIEW mart.mv_high_risk_customer_snapshot;
END;
$$;

CREATE OR REPLACE FUNCTION audit.table_row_counts()
RETURNS TABLE(schema_name text, table_name text, estimated_rows bigint)
LANGUAGE sql
STABLE
AS $$
    SELECT
        schemaname::text AS schema_name,
        relname::text AS table_name,
        n_live_tup::bigint AS estimated_rows
    FROM pg_stat_user_tables
    WHERE schemaname IN ('banking','mart')
    ORDER BY schemaname, relname;
$$;
