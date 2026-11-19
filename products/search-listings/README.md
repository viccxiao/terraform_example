# search-listings (next after the pilot)

Same shape as `products/smart-tags/`. Moves out of the workspaces root:

- `autoloader_search_listings.tf`, `jobs_autoloader_search_listings.tf`

Other products follow the same pattern, one at a time:

| Product | Files leaving the workspaces root |
|---|---|
| image-tagger | `jobs_image_tagger.tf`, `locals_image_tagger.tf`, `image_tagger_portal_export.tf` |
| text-tagger | `jobs_text_tagger.tf`, `locals_text_tagger.tf`, `text_tagger_portal_export.tf` |
| agent-harness | `jobs_agent_harness.tf`, `notebooks_agent_harness.tf`, `agent_harness_*.tf`, `tables_companion.tf` |
