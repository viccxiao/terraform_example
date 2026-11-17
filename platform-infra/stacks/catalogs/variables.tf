variable "catalogs" {
  description = "One catalog per environment plus ds for long-running data science work."
  type = map(object({
    storage_root = string
    comment      = string
  }))
}

variable "workspace_ids" {
  description = "Workspace IDs by environment."
  type        = map(number)
}

variable "bindings" {
  description = "Which catalogs each workspace can see, and whether read-write or read-only."
  type = list(object({
    catalog   = string
    workspace = string
    read_only = optional(bool, false)
  }))
}

variable "bundle_ci_service_principal" {
  description = "Application ID of the CI principal that creates and drops pr_<n> schemas in dev."
  type        = string
}
