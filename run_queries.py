"""Run every query in queries/ against the built warehouse and print results."""
from pathlib import Path
import duckdb

con = duckdb.connect("antaq.duckdb", read_only=True)
for sql_file in sorted(Path("queries").glob("*.sql")):
    print("\n" + "=" * 70)
    print(sql_file.name)
    print("=" * 70)
    sql = sql_file.read_text()
    print(con.execute(sql).fetchdf().to_string(index=False))
con.close()
