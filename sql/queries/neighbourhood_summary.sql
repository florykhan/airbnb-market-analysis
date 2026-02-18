-- Neighbourhood summary: one row per neighbourhood with key metrics.
-- Excludes NULL neighbourhood/price; applies price outlier filter (20–1000).
-- Run: sqlite3 data/airbnb.db < sql/queries/neighbourhood_summary.sql

WITH filtered AS (
    -- Step 1: Apply filters before aggregation.
    -- Exclude NULL neighbourhood and price; filter extreme price outliers.
    SELECT *
    FROM listings
    WHERE neighbourhood IS NOT NULL
      AND price IS NOT NULL
      AND price BETWEEN 20 AND 1000
),

ranked_prices AS (
    -- Step 2: Rank prices within each neighbourhood for median calculation.
    -- SQLite has no MEDIAN(); we compute it via window functions.
    SELECT neighbourhood,
           price,
           ROW_NUMBER() OVER (PARTITION BY neighbourhood ORDER BY price) AS rn,
           COUNT(*) OVER (PARTITION BY neighbourhood) AS cnt
    FROM filtered
),

median_by_neighbourhood AS (
    -- Step 3: Median = middle value (odd n) or avg of two middle values (even n).
    SELECT neighbourhood,
           AVG(price) AS median_price
    FROM ranked_prices
    WHERE (cnt % 2 = 1 AND rn = (cnt + 1) / 2)
       OR (cnt % 2 = 0 AND rn IN (cnt / 2, cnt / 2 + 1))
    GROUP BY neighbourhood
),

agg AS (
    -- Step 4: Aggregate counts and averages per neighbourhood.
    SELECT neighbourhood,
           COUNT(*) AS listing_count,
           AVG(price) AS avg_price,
           AVG(number_of_reviews) AS avg_reviews,
           SUM(CASE WHEN room_type = 'Entire home/apt' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_entire_home,
           AVG(availability_365) AS avg_availability_365,
           AVG(minimum_nights) AS avg_minimum_nights
    FROM filtered
    GROUP BY neighbourhood
)

-- Step 5: Join aggregates with median and output, ordered by popularity.
SELECT a.neighbourhood,
       a.listing_count,
       ROUND(a.avg_price, 2) AS avg_price,
       ROUND(m.median_price, 2) AS median_price,
       ROUND(a.avg_reviews, 2) AS avg_reviews,
       ROUND(a.pct_entire_home, 2) AS pct_entire_home,
       ROUND(a.avg_availability_365, 2) AS avg_availability_365,
       ROUND(a.avg_minimum_nights, 2) AS avg_minimum_nights
FROM agg a
JOIN median_by_neighbourhood m ON a.neighbourhood = m.neighbourhood
ORDER BY a.listing_count DESC;
