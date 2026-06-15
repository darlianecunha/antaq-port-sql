"""Build the antaq-port-sql DuckDB warehouse from CSV sources.

Usage:
    python load.py                      # uses data/sample/
    python load.py --data path/to/csvs  # point at real ANTAQ extracts

Real ANTAQ data: download the 'Estatístico Aquaviário' base at
https://web3.antaq.gov.br/ea/sense/download.html and map its columns to the
expected schema (see README). The sample mirrors that structure at small scale.
"""
from __future__ import annotations

import argparse
from pathlib import Path

import duckdb


def build(data_dir: str = "data/sample", db_path: str = "antaq.duckdb") -> None:
    data = Path(data_dir)
    con = duckdb.connect(db_path)
    con.execute(open("schema.sql").read())

    # Dimensions (load straight from CSV)
    con.execute(f"INSERT INTO dim_porto SELECT * FROM read_csv_auto('{data/'ports.csv'}')")
    con.execute(f"INSERT INTO dim_navio SELECT * FROM read_csv_auto('{data/'vessels.csv'}')")

    # Fact: berthings, with derived dwell time / year / month
    con.execute(f"""
        INSERT INTO fato_atracacao
        SELECT berthing_id, port_id, vessel_id,
               berth_start, berth_end,
               ROUND(date_diff('minute', berth_start, berth_end) / 60.0, 2) AS berth_hours,
               year(berth_start)  AS berth_year,
               month(berth_start) AS berth_month
        FROM read_csv_auto('{data/'berthings.csv'}',
                           types={{'berth_start':'TIMESTAMP','berth_end':'TIMESTAMP'}})
    """)

    # Fact: cargo movements
    con.execute(f"INSERT INTO fato_movimentacao SELECT * FROM read_csv_auto('{data/'cargo_movements.csv'}')")

    counts = con.execute("""
        SELECT 'dim_porto' t, COUNT(*) n FROM dim_porto
        UNION ALL SELECT 'dim_navio', COUNT(*) FROM dim_navio
        UNION ALL SELECT 'fato_atracacao', COUNT(*) FROM fato_atracacao
        UNION ALL SELECT 'fato_movimentacao', COUNT(*) FROM fato_movimentacao
    """).fetchall()
    print("Warehouse built:", db_path)
    for t, n in counts:
        print(f"  {t:18s} {n}")
    con.close()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default="data/sample")
    ap.add_argument("--db", default="antaq.duckdb")
    args = ap.parse_args()
    build(args.data, args.db)
