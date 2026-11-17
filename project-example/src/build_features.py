"""Reads DE's gold table (read-only) and writes features to this project's own schema."""
import argparse

from pyspark.sql import SparkSession, functions as F

parser = argparse.ArgumentParser()
parser.add_argument("--source", required=True)
parser.add_argument("--target", required=True)
args = parser.parse_args()

spark = SparkSession.builder.getOrCreate()

features = (
    spark.table(args.source)
    .groupBy("postcode_district", "bedrooms")
    .agg(
        F.percentile_approx("price", 0.5).alias("median_price"),
        F.count("*").alias("listings"),
        F.max("updated_at").alias("as_of"),
    )
)

# Catalog and schema come from the bundle target, so the same code writes to
# dev.pr_123, ds.ds_pricing_scratch, stg.ds_pricing or prod.ds_pricing.
features.write.mode("overwrite").saveAsTable(args.target)
print(f"Wrote {features.count()} rows to {args.target}")
