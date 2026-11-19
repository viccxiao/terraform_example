"""Builds the image golden set. Placeholder logic: replace with the real Smart Tags code."""
import argparse

import mlflow
from pyspark.sql import SparkSession, functions as F

parser = argparse.ArgumentParser()
parser.add_argument("--source", required=True)
parser.add_argument("--target", required=True)
parser.add_argument("--experiment", required=True)
args = parser.parse_args()

spark = SparkSession.builder.getOrCreate()
mlflow.set_experiment(args.experiment)

golden = (
    spark.table(args.source)
    .where(F.col("image_url").isNotNull())
    .select("listing_id", "image_url", "property_type", "updated_at")
    .sample(fraction=0.01, seed=42)
)

# The table is created by the pipeline in its own schema, not by Terraform.
# Catalog and schema come from the bundle target: dev.pr_123, qa.smart_tags, prod.smart_tags ...
golden.write.mode("overwrite").saveAsTable(args.target)

with mlflow.start_run(run_name="build_golden_set"):
    mlflow.log_metric("rows", golden.count())
    mlflow.log_param("target", args.target)
