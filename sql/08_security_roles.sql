\echo 'Creating example security roles for a governed analytics database...'

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'banking_readonly') THEN
        CREATE ROLE banking_readonly;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'banking_analyst') THEN
        CREATE ROLE banking_analyst;
    END IF;
END $$;

GRANT USAGE ON SCHEMA banking, mart TO banking_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA banking, mart TO banking_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA banking GRANT SELECT ON TABLES TO banking_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA mart GRANT SELECT ON TABLES TO banking_readonly;

GRANT banking_readonly TO banking_analyst;
GRANT USAGE ON SCHEMA audit TO banking_analyst;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA audit TO banking_analyst;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA mart TO banking_analyst;

-- Optional production hardening pattern:
-- REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- ALTER ROLE banking_analyst SET search_path = mart, banking, public;
