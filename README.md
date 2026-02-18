# 🏠 Vancouver Airbnb Market Analysis — SQL + Tableau

This repository implements an **end-to-end data analytics workflow** for Vancouver Airbnb listing data: from raw CSV ingestion and SQLite storage, through SQL-based aggregation and export, to an **interactive Tableau dashboard** that communicates pricing, neighbourhood, and room-type insights. The project demonstrates practical data analyst skills — relational querying, exploratory analysis, and dashboard-driven storytelling — using the **Inside Airbnb** Vancouver dataset.

---

## 🎯 Project Overview

The goal is to:
- **Load and clean** Airbnb listing and review data into a SQLite database with a well-defined schema.
- **Answer business questions** using SQL: neighbourhood-level metrics (median/avg price, listing counts, occupancy, room-type mix) and room-type summaries.
- **Export analytical results** to CSV for use in Tableau.
- **Build an interactive dashboard** (Tableau Public) showcasing Vancouver Airbnb prices by neighbourhoods and room types, including a map view.
- **Document the workflow** so that raw data → database → queries → exports → dashboard is reproducible and easy to follow.

The project simulates a real-world data analyst task where stakeholders need clear, visual answers to questions about market performance and pricing patterns.

---

## ✨ Key Features

- **Structured data pipeline:** Raw CSVs → Python ETL (`scripts/load_to_db.py`) → SQLite (`data/airbnb.db`) with proper price cleaning and date handling.
- **SQL-first analytics:** Reusable SQL queries in `sql/queries/` that compute median prices (via window functions), averages, and counts; filters exclude NULLs and extreme price outliers ($20–$1000) for sensible summaries.
- **Neighbourhood summary:** One row per neighbourhood with listing count, average/median price, average reviews, % entire home/apt, average availability (365), and average minimum nights — ordered by listing count.
- **Room type summary:** One row per room type with listing count, average price, and median price — supporting comparison across Entire home/apt, Private room, Shared room, etc.
- **Export scripts:** Python scripts that run the stored SQL and write results to `data/processed/` as CSV, ready for Tableau (or other tools).
- **Interactive Tableau dashboard:** Public dashboard linking Vancouver Airbnb prices to neighbourhoods and room types, with a map and key metrics.
- **Exploratory notebook:** `notebooks/01_exploration.ipynb` for EDA, sanity checks, and informing SQL and dashboard design (not the primary deliverable).

---

## 📊 Tableau Dashboard

The main deliverable for visual storytelling is an interactive dashboard published on Tableau Public:

**[Vancouver Airbnb Prices — Neighbourhoods & Room Types](https://public.tableau.com/app/profile/ilian.khankhalaev/viz/VancouverAirbnbPricesNeighbourhoodsRoomTypes/Dashboard1?publish=yes)**

The dashboard explores how Airbnb prices vary across Vancouver neighbourhoods, room types, and listing popularity. It includes:

- **Vancouver Airbnb: Median Price by Neighbourhood** — A choropleth map of Vancouver where neighbourhoods are shaded by median nightly price (darker blue = higher price), giving a quick geographic view of where listings are pricier.
- **Airbnb Price vs Reviews (Vancouver)** — A scatter plot of Price per Night (CAD) vs Number of Reviews, showing how price and review volume relate across listings (e.g. concentration at lower prices and fewer reviews).
- **Median Airbnb Price by Room Type (Vancouver)** — A horizontal bar chart comparing median price for Entire home/apt, Private room, and Shared room (e.g. entire homes highest, shared rooms lowest).
- **Top 10 Neighbourhoods by Median Price** — A horizontal bar chart of the neighbourhoods with the highest median nightly price (e.g. Downtown, Kitsilano, Downtown Eastside).

**Interactive filters** let you narrow the view: sliders for Avg Listing Price (CAD), % Entire Home Listings, and Median Nightly Price (CAD), plus a Room Type legend (Entire home/apt, Hotel room, Private room, Shared room) to focus on specific listing types.

Use the link above to explore the dashboard in your browser (no Tableau installation required).

---

## 🧱 Repository Structure

```
airbnb-market-analysis/
│
├── data/
│   ├── raw/                                  # Unmodified input data (not in Git: large CSVs/GeoJSON)
│   │   ├── listings.csv                      # Inside Airbnb Vancouver listings
│   │   ├── reviews.csv                       # Reviews (listing_id, date)
│   │   └── neighbourhoods.geojson           # Neighbourhood boundaries for mapping
│   ├── processed/                            # Query outputs for Tableau (CSV)
│   │   ├── neighbourhood_summary.csv         # One row per neighbourhood
│   │   └── room_type_summary.csv             # One row per room type
│   └── airbnb.db                             # SQLite database (not in Git; generated by load script)
│
├── notebooks/
│   └── 01_exploration.ipynb                  # EDA: distributions, sanity checks, visuals
│
├── scripts/
│   ├── load_to_db.py                         # ETL: CSV → SQLite (clean price, dates; create tables)
│   ├── export_neighbourhood_summary.py       # Run neighbourhood SQL → CSV
│   └── export_room_type_summary.py           # Run room type SQL → CSV
│
├── sql/
│   ├── schema/
│   │   └── create_tables.sql                 # Listings + Reviews table definitions
│   └── queries/
│       ├── neighbourhood_summary.sql        # Per-neighbourhood metrics (median price, counts, etc.)
│       └── room_type_summary.sql            # Per–room type metrics (count, avg, median price)
│
├── .gitignore
├── LICENSE
└── README.md
```

> 🗒️ **Note:**  
> - The `data/raw/` directory is **not tracked** (large CSVs and GeoJSON). Place `listings.csv` and `reviews.csv` from [Inside Airbnb](http://insideairbnb.com/get-the-data/) for Vancouver there before running the pipeline.  
> - The SQLite database `data/airbnb.db` is **not in Git**; it is created by `scripts/load_to_db.py`.  
> - The `data/processed/*.csv` files are **tracked** so that the Tableau workflow can be reproduced or inspected without re-running exports.

---

## 🧰 Run Locally

You can reproduce the pipeline on your machine using **Python 3** (e.g. 3.9+) with `pandas` and the standard library `sqlite3`.

### 1️⃣ Clone the repository

**HTTPS (recommended for most users):**
```bash
git clone https://github.com/florykhan/airbnb-market-analysis.git
cd airbnb-market-analysis
```
**SSH (for users who have SSH keys configured):**
```bash
git clone git@github.com:florykhan/airbnb-market-analysis.git
cd airbnb-market-analysis
```

### 2️⃣ Create and activate a virtual environment (optional but recommended)

```bash
python3 -m venv venv
source venv/bin/activate      # macOS/Linux
# venv\Scripts\activate       # Windows
```

### 3️⃣ Install dependencies

```bash
pip install pandas
```
(`sqlite3` is part of the Python standard library.)

### 4️⃣ Add the raw data

Download the Vancouver dataset from [Inside Airbnb](http://insideairbnb.com/get-the-data/) and place the files in `data/raw/`:

- `listings.csv`
- `reviews.csv` (optional; used for review-level analysis if needed)
- `neighbourhoods.geojson` (optional; for Tableau map layers)

```bash
# Example: ensure directory exists and place files there
mkdir -p data/raw
# Then copy listings.csv, reviews.csv (and optionally neighbourhoods.geojson) into data/raw/
```

### 5️⃣ Load data into SQLite

This step creates (or replaces) `data/airbnb.db`, cleans prices (strip `$` and commas, convert to numeric), normalizes dates, and loads listings and reviews.

```bash
python scripts/load_to_db.py
```

You should see output similar to:
- `Loaded X,XXX rows into listings.`
- `NULL prices: X`
- `Loaded X,XXX rows into reviews.` (if `reviews.csv` is present)

### 6️⃣ Export summary CSVs for Tableau

Run the SQL queries and export results to `data/processed/`:

```bash
python scripts/export_neighbourhood_summary.py
python scripts/export_room_type_summary.py
```

Output files:
- `data/processed/neighbourhood_summary.csv`
- `data/processed/room_type_summary.csv`

Connect these (and optionally `data/raw/neighbourhoods.geojson`) to your Tableau workbook to reproduce or extend the dashboard.

### 7️⃣ (Optional) Run the EDA notebook

For exploration and sanity checks:

```bash
jupyter notebook notebooks/01_exploration.ipynb
```

---

## 📈 Analytical Queries (Summary)

| Query | Purpose |
|-------|--------|
| **neighbourhood_summary.sql** | One row per neighbourhood: listing count, avg/median price, avg reviews, % entire home, avg availability_365, avg minimum_nights. Excludes NULL neighbourhood/price and prices outside $20–$1000. |
| **room_type_summary.sql** | One row per room type: listing count, avg price, median price. Same price and NULL filters. |

Median price is computed in SQL using window functions (`ROW_NUMBER`, `PARTITION BY`) to support robust reporting. You can run the queries directly with SQLite:

```bash
sqlite3 data/airbnb.db < sql/queries/neighbourhood_summary.sql
sqlite3 data/airbnb.db < sql/queries/room_type_summary.sql
```

---

## 🔍 Key Questions Answered

- **Which neighbourhoods have the most listings, and how do prices vary?** — Neighbourhood summary and dashboard map.
- **How do different room types compare in count and price?** — Room type summary and dashboard.
- **What is the typical (median) price per neighbourhood or room type?** — SQL median logic and exported CSVs.
- **How do availability, minimum nights, and % entire home vary by neighbourhood?** — Neighbourhood summary columns and Tableau visuals.

---

## 🧠 Tech Stack

- **Language:** Python 3 (3.9+)
- **Data & DB:** pandas, SQLite (stdlib)
- **Analytics:** SQL (schema + analytical queries in `sql/`)
- **Visualization:** Tableau Public (dashboard); Jupyter + matplotlib/seaborn (EDA notebook)
- **Version control:** Git + GitHub

---

## 🧾 License

MIT License — feel free to use and modify with attribution.  
See the [`LICENSE`](./LICENSE) file for full details.

---

## 👤 Author

**Ilian Khankhalaev**  
_BSc Computing Science, Simon Fraser University_  
📍 Vancouver, BC  |  [florykhan@gmail.com](mailto:florykhan@gmail.com)  |  [GitHub](https://github.com/florykhan)  |  [LinkedIn](https://www.linkedin.com/in/ilian-khankhalaev/)
