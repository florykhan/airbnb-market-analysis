"""
Load Airbnb Vancouver data into SQLite.
Safe to re-run: drops and recreates tables before loading.
"""

import sqlite3
from pathlib import Path

import pandas as pd

# Paths (script run from project root)
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "data" / "airbnb.db"
LISTINGS_CSV = PROJECT_ROOT / "data" / "raw" / "listings.csv"
REVIEWS_CSV = PROJECT_ROOT / "data" / "raw" / "reviews.csv"
SCHEMA_SQL = PROJECT_ROOT / "sql" / "schema" / "create_tables.sql"


def clean_price(series: pd.Series) -> pd.Series:
    """Convert price strings like '$1,234' to float; empty/invalid -> NaN."""
    if series.dtype == float or series.dtype == "int64":
        return series
    cleaned = series.astype(str).str.replace("$", "", regex=False).str.replace(",", "", regex=False)
    return pd.to_numeric(cleaned, errors="coerce")


def main() -> None:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    # Load listings
    df_listings = pd.read_csv(LISTINGS_CSV)

    # Clean price: strip $ and commas, convert to float, empty/invalid -> NaN
    df_listings["price"] = clean_price(df_listings["price"])

    # Convert last_review to ISO date string; empty/invalid -> None (NULL in SQL)
    last_review_dt = pd.to_datetime(df_listings["last_review"], errors="coerce")
    df_listings["last_review"] = last_review_dt.dt.strftime("%Y-%m-%d").where(
        last_review_dt.notna(), None
    )

    conn = sqlite3.connect(DB_PATH)

    try:
        cursor = conn.cursor()

        # Drop tables for safe re-run (reviews first due to FK)
        cursor.execute("DROP TABLE IF EXISTS reviews;")
        cursor.execute("DROP TABLE IF EXISTS listings;")

        # Create tables from schema
        schema_sql = SCHEMA_SQL.read_text()
        cursor.executescript(schema_sql)

        # Insert listings
        df_listings.to_sql("listings", conn, if_exists="append", index=False)

        reviews_loaded = False
        if REVIEWS_CSV.exists():
            df_reviews = pd.read_csv(REVIEWS_CSV)
            df_reviews = df_reviews[["listing_id", "date"]]
            df_reviews.to_sql("reviews", conn, if_exists="append", index=False)
            reviews_loaded = True

        conn.commit()

        # Summary
        n_listings = cursor.execute("SELECT COUNT(*) FROM listings").fetchone()[0]
        null_prices = cursor.execute("SELECT COUNT(*) FROM listings WHERE price IS NULL").fetchone()[0]

        print(f"Loaded {n_listings:,} rows into listings.")
        print(f"NULL prices: {null_prices:,}")
        if reviews_loaded:
            n_reviews = cursor.execute("SELECT COUNT(*) FROM reviews").fetchone()[0]
            print(f"Loaded {n_reviews:,} rows into reviews.")
        else:
            print("Reviews: not loaded (file not found).")

    finally:
        conn.close()


if __name__ == "__main__":
    main()
