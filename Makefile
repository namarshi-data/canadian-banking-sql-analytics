DB_SERVICE=postgres
DB_CONTAINER=canadian_banking_postgres
DB_NAME=canadian_banking
DB_USER=banking_admin
PSQL=docker compose exec -T $(DB_SERVICE) psql -v ON_ERROR_STOP=1 -U $(DB_USER) -d $(DB_NAME)

.PHONY: up wait-db down reset build rebuild all setup load constraints marts tests cases performance advanced shell profile

up:
	docker compose up -d

wait-db:
	docker compose exec -T $(DB_SERVICE) bash -lc "until pg_isready -U $(DB_USER) -d $(DB_NAME); do echo waiting for postgres; sleep 2; done"

build: wait-db
	$(PSQL) -f /sql/run_all.sql

setup: wait-db
	$(PSQL) -f /sql/00_setup.sql
	$(PSQL) -f /sql/01_create_tables.sql

load: wait-db
	$(PSQL) -f /sql/02_load_csv_postgres.sql

constraints: wait-db
	$(PSQL) -f /sql/03_constraints_indexes.sql

marts: wait-db
	$(PSQL) -f /sql/05_business_views.sql
	$(PSQL) -f /sql/06_materialized_views.sql
	$(PSQL) -f /sql/07_functions_procedures.sql
	$(PSQL) -f /sql/08_security_roles.sql

performance: wait-db
	$(PSQL) -f /sql/09_performance_tuning_examples.sql

tests: wait-db
	$(PSQL) -f /sql/04_data_quality_tests.sql
	$(PSQL) -f /tests/reconciliation_checks.sql
	$(PSQL) -f /tests/data_quality_assertions.sql

cases: wait-db
	$(PSQL) -f /sql/10_analyst_case_studies.sql

advanced: wait-db
	$(PSQL) -f /sql/run_advanced.sql

all: up build

rebuild: reset build

profile:
	python scripts/profile_dataset.py

shell: wait-db
	docker compose exec $(DB_SERVICE) psql -U $(DB_USER) -d $(DB_NAME)

down:
	docker compose down

reset:
	docker compose down -v --remove-orphans
	docker compose up -d
	$(MAKE) wait-db
