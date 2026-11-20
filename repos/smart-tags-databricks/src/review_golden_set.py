"""Weekly check on the golden set. Placeholder logic: replace with the real review."""
import argparse

from pyspark.sql import SparkSession

parser = argparse.ArgumentParser()
parser.add_argument("--table", required=True)
args = parser.parse_args()

spark = SparkSession.builder.getOrCreate()
rows = spark.table(args.table).count()
if rows == 0:
    raise SystemExit(f"{args.table} is empty")
print(f"{args.table}: {rows} rows")
