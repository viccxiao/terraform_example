"""Fail fast if DE's published table no longer has the columns this project relies on."""
import argparse

from pyspark.sql import SparkSession

EXPECTED = {
    "listing_id": "string",
    "price": "bigint",
    "postcode_district": "string",
    "bedrooms": "int",
    "updated_at": "timestamp",
}

parser = argparse.ArgumentParser()
parser.add_argument("--source", required=True)
args = parser.parse_args()

spark = SparkSession.builder.getOrCreate()
actual = {f.name: f.dataType.simpleString() for f in spark.table(args.source).schema.fields}

problems = [
    f"{col}: expected {typ}, found {actual.get(col, 'missing')}"
    for col, typ in EXPECTED.items()
    if actual.get(col) != typ
]
if problems:
    raise SystemExit(f"Contract broken on {args.source}:\n" + "\n".join(problems))
print(f"Contract OK on {args.source}")
