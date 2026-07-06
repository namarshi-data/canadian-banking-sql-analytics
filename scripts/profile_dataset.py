from pathlib import Path
import pandas as pd

BASE = Path(__file__).resolve().parents[1]
RAW = BASE / 'data' / 'raw'

rows = []
for path in sorted(RAW.glob('*.csv')):
    df = pd.read_csv(path, nrows=1000)
    total_rows = sum(1 for _ in open(path, 'rb')) - 1
    rows.append({
        'table': path.stem,
        'rows': total_rows,
        'columns': len(df.columns),
        'sample_columns': ', '.join(df.columns[:8])
    })

profile = pd.DataFrame(rows).sort_values('table')
print(profile.to_string(index=False))
print()
print(f"Total rows: {profile['rows'].sum():,}")
