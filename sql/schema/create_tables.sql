-- Schema for Inside Airbnb Vancouver dataset
-- Tables match data/raw/listings.csv and data/raw/reviews.csv
-- Do not load data here; tables only.

-- -----------------------------------------------------------------------------
-- Listings table
-- -----------------------------------------------------------------------------
-- Source: data/raw/listings.csv
-- Note: price is stored as string in CSV (e.g. "136", "$100") and may be empty;
--       use REAL to allow numeric values and NULLs for missing prices.
--       Strip "$" and commas during ETL before inserting.
-- -----------------------------------------------------------------------------
CREATE TABLE listings (
    id                          INTEGER PRIMARY KEY,
    name                        TEXT,
    host_id                     INTEGER,
    host_name                   TEXT,
    neighbourhood_group         TEXT,
    neighbourhood               TEXT,
    latitude                    REAL,
    longitude                   REAL,
    room_type                   TEXT,
    price                       REAL,       -- CSV: string; convert to numeric, NULL if empty
    minimum_nights              INTEGER,
    number_of_reviews           INTEGER,
    last_review                 TEXT,       -- DATE as ISO8601 (YYYY-MM-DD); NULL if no reviews
    reviews_per_month           REAL,
    calculated_host_listings_count INTEGER,
    availability_365            INTEGER,
    number_of_reviews_ltm       INTEGER,
    license                     TEXT
);

-- -----------------------------------------------------------------------------
-- Reviews table
-- -----------------------------------------------------------------------------
-- Source: data/raw/reviews.csv
-- listing_id references listings.id
-- -----------------------------------------------------------------------------
CREATE TABLE reviews (
    listing_id                  INTEGER NOT NULL REFERENCES listings(id),
    date                        TEXT NOT NULL    -- DATE as ISO8601 (YYYY-MM-DD)
);
