# Moving a product out of the workspaces root (no downtime, no data loss)

Example: Smart Tags. Repeat per product.

1. **Deploy nothing yet.** Write the bundle in `repos/smart-tags-databricks/` and run `databricks bundle validate`.
2. **Remove from Terraform state, keep the real resources.** Add `smart_tags_removed.tf` to the workspaces root and delete the old `*_smart_tags_*.tf` files in the same PR. Terraform plans `0 to destroy` and only forgets them.
3. **Let the bundle take over the existing resources** instead of creating duplicates:
   ```
   databricks bundle deployment bind image_golden <existing-job-id> -t qa
   databricks bundle deployment bind image_golden_review <existing-job-id> -t qa

   ```
   Repeat for prod. Then `databricks bundle deploy -t qa`.
4. **Schemas and grants** move into `repos/smart-tags-databricks/terraform/project.yaml`. Use `import` blocks in the project's Terraform so existing schemas are adopted, not recreated.
5. **Tables stay where they are.** The pipeline writes to them from now on. Terraform no longer owns them.
6. **Notebooks** move from `notebooks/` in the workspaces repo to `repos/smart-tags-databricks/src/`.

Check the plan in step 2 shows **no destroys** before merging.
