"""
Export neighbourhood summary from SQLite to CSV.
Reads SQL from sql/queries/neighbourhood_summary.sql, executes it, and saves to data/processed/.
"""

import sqlite3
from pathlib import Path

import pandas as pd

# Paths (script run from project root)
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "data" / "airbnb.db"
QUERY_PATH = PROJECT_ROOT / "sql" / "queries" / "neighbourhood_summary.sql"
OUTPUT_PATH = PROJECT_ROOT / "data" / "processed" / "neighbourhood_summary.csv"


def main() -> None:
    query = QUERY_PATH.read_text()
    conn = sqlite3.connect(DB_PATH)
    try:
        df = pd.read_sql_query(query, conn)
    finally:
        conn.close()

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)
    print(f"Exported {len(df):,} rows to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
