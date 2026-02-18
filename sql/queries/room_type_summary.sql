-- Room type summary: one row per room type with key metrics.
-- Excludes NULL room_type/price; applies price outlier filter (20–1000).
-- Run: sqlite3 data/airbnb.db < sql/queries/room_type_summary.sql

WITH filtered AS (
    SELECT *
    FROM listings
    WHERE room_type IS NOT NULL
      AND price IS NOT NULL
      AND price BETWEEN 20 AND 1000
),

ranked_prices AS (
    SELECT room_type,
           price,
           ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY price) AS rn,
           COUNT(*) OVER (PARTITION BY room_type) AS cnt
    FROM filtered
),

median_by_room_type AS (
    SELECT room_type,
           AVG(price) AS median_price
    FROM ranked_prices
    WHERE (cnt % 2 = 1 AND rn = (cnt + 1) / 2)
       OR (cnt % 2 = 0 AND rn IN (cnt / 2, cnt / 2 + 1))
    GROUP BY room_type
),

agg AS (
    SELECT room_type,
           COUNT(*) AS listing_count,
           AVG(price) AS avg_price
    FROM filtered
    GROUP BY room_type
)

SELECT a.room_type,
       a.listing_count,
       ROUND(a.avg_price, 2) AS avg_price,
       ROUND(m.median_price, 2) AS median_price
FROM agg a
JOIN median_by_room_type m ON a.room_type = m.room_type
ORDER BY a.listing_count DESC;
