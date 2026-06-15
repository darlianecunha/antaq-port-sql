# antaq-port-sql

> Reproducible SQL data warehouse of Brazilian port operations, built from ANTAQ-style open data, with documented analytical queries that reproduce sector indicators.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org)
[![DuckDB](https://img.shields.io/badge/SQL-DuckDB-yellow.svg)](https://duckdb.org)

## What this is

A small, fully reproducible star-schema warehouse of Brazilian port operations (berthings and cargo movements), with a library of documented SQL queries. It mirrors the structure of the **ANTAQ Estatístico Aquaviário** open microdata and operationalises a subset of the port-sector indicators catalogued in national port data-collection efforts (movements, average berthing times, year-over-year growth, cargo-nature mix, seasonality).

The repository ships with a synthetic sample so everything runs out of the box; the same schema and queries work on the real ANTAQ extracts.

## Data model (star schema)

```
dim_porto ──┐
            ├── fato_atracacao ── fato_movimentacao
dim_navio ──┘
```

| Table | Grain | Key columns |
|---|---|---|
| `dim_porto` | one row per port/terminal | port_id, port_name, state, port_type |
| `dim_navio` | one row per vessel | vessel_id, imo, vessel_type, dwt |
| `fato_atracacao` | one row per berthing | berthing_id, port_id, vessel_id, berth_hours, berth_year |
| `fato_movimentacao` | one row per cargo movement | movement_id, berthing_id, cargo_nature, tonnes, direction |

## Indicators implemented (query → technique)

| Query | Indicator | SQL technique |
|---|---|---|
| `01_top_ports_by_cargo.sql` | Top ports by cargo (2024) | JOIN, GROUP BY, ORDER BY, LIMIT |
| `02_avg_berth_time.sql` | Avg berthing time by port/year | AVG, GROUP BY |
| `03_yoy_growth.sql` | Year-over-year cargo growth | CTE + LAG() window |
| `04_cargo_nature_mix.sql` | Cargo nature mix per port | conditional aggregation (CASE) |
| `05_rank_within_vessel_type.sql` | Port ranking within vessel type | RANK() window |
| `06_monthly_seasonality.sql` | Monthly berthings + 3-month moving avg | windowed frame (ROWS BETWEEN) |

## Quick start

```bash
pip install -r requirements.txt
python load.py          # builds antaq.duckdb from data/sample
python run_queries.py   # runs every query and prints results
```

Or interactively in `notebooks/01_explore.ipynb`.

## Using real ANTAQ data

1. Download the *Estatístico Aquaviário* base at <https://web3.antaq.gov.br/ea/sense/download.html>.
2. Map its fields to the expected columns (berthing dates, port, vessel, cargo nature, tonnes, direction). The sample CSVs document the target shape.
3. Run `python load.py --data path/to/your/csvs`.

## Repository structure

```
antaq-port-sql/
├── schema.sql            # DDL (dimensions + facts)
├── load.py               # ETL: CSV -> DuckDB star schema
├── run_queries.py        # run all queries
├── queries/              # one documented .sql per indicator
├── data/sample/          # synthetic sample (ports, vessels, berthings, cargo)
└── notebooks/            # interactive exploration
```

## Data note

The sample data is **synthetic** and for demonstration only. Real figures must come from the ANTAQ Estatístico Aquaviário. Cargo-nature labels follow ANTAQ conventions (granel sólido, granel líquido, conteinerizada, carga geral).

## License

Code: MIT · Real data: ANTAQ open data under its own terms.
