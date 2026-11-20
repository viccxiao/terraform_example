"""Tags listings. Placeholder logic: replace with the real Smart Tags tagger for each kind."""
import argparse

from pyspark.sql import SparkSession, functions as F

parser = argparse.ArgumentParser()
parser.add_argument("--kind", required=True, choices=["image", "floor_plan", "text"])
parser.add_argument("--source", required=True)
parser.add_argument("--target", required=True)
args = parser.parse_args()

spark = SparkSession.builder.getOrCreate()

column = {"image": "image_url", "floor_plan": "floor_plan_url", "text": "description"}[args.kind]
tags = (
    spark.table(args.source)
    .where(F.col(column).isNotNull())
    .select("listing_id", F.lit(args.kind).alias("kind"), F.current_timestamp().alias("tagged_at"))
)

# The table belongs to this project and is created by the job, not by Terraform.
tags.write.mode("overwrite").saveAsTable(args.target)
print(f"{args.kind}: wrote {tags.count()} rows to {args.target}")
