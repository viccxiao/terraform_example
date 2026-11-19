# Add to the workspaces root in the same PR that deletes the Smart Tags files.
# Terraform forgets these resources without deleting them (Terraform >= 1.7).
# Module and resource names are illustrative: match the names in your code.

removed {
  from = module.jobs_smart_tags_image_golden
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.jobs_smart_tags_image_golden_review
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.notebooks_smart_tags
  lifecycle {
    destroy = false
  }
}

removed {
  from = databricks_mlflow_experiment.smart_tags
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.tables_smart_tags_image_golden
  lifecycle {
    destroy = false
  }
}
