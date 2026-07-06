from pathlib import Path

import pandas as pd

BASE = Path(__file__).resolve().parents[1]
RAW = BASE / "data" / "raw"


def read(name: str) -> pd.DataFrame:
    return pd.read_csv(RAW / f"{name}.csv")


def status(name: str, passed: bool, exceptions: int = 0) -> None:
    label = "PASS" if passed else "REVIEW"
    print(f"{name}: {label} ({exceptions} exception(s))")


customers = read("dim_customers")
accounts = read("fact_accounts")
transactions = read("fact_transactions")
dates = read("dim_date")
risk_history = read("fact_customer_risk_history")
campaign_contacts = read("fact_campaign_contacts")

# Match the PostgreSQL load rule: transaction date_key is derived from transaction_date,
# and dim_date is enriched for valid transaction dates outside the seed calendar.
transaction_dates = pd.to_datetime(transactions["transaction_date"], errors="coerce")
derived_transaction_date_keys = transaction_dates.dt.strftime("%Y%m%d").astype("Int64")
post_load_date_keys = set(dates["date_key"].astype(int)) | set(derived_transaction_date_keys.dropna().astype(int))

checks = [
    ("customer_id_unique", customers["customer_id"].is_unique, customers["customer_id"].duplicated().sum()),
    ("account_id_unique", accounts["account_id"].is_unique, accounts["account_id"].duplicated().sum()),
    ("transaction_id_unique", transactions["transaction_id"].is_unique, transactions["transaction_id"].duplicated().sum()),
    ("account_customer_fk_valid", accounts["customer_id"].isin(customers["customer_id"]).all(), (~accounts["customer_id"].isin(customers["customer_id"])).sum()),
    ("transaction_date_key_covered_after_enrichment", derived_transaction_date_keys.isin(post_load_date_keys).all(), (~derived_transaction_date_keys.isin(post_load_date_keys)).sum()),
    ("campaign_non_null_customer_ids_valid", campaign_contacts.loc[campaign_contacts["customer_id"].notna(), "customer_id"].isin(customers["customer_id"]).all(), (~campaign_contacts.loc[campaign_contacts["customer_id"].notna(), "customer_id"].isin(customers["customer_id"])).sum()),
]

for name, passed, exceptions in checks:
    status(name, bool(passed), int(exceptions))

no_score_rows = risk_history["credit_score"].isna().sum()
print(f"risk_no_score_records_standardized_during_sql_load: INFO ({no_score_rows} record(s))")
