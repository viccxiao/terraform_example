variable "project" {
  description = "Project name, used for naming the deploy service principal."
  type        = string
}

variable "owners_group" {
  description = "Existing account group for the people working on the project."
  type        = string
}

variable "schemas" {
  description = "Schemas this project owns. Readers get SELECT only."
  type = list(object({
    catalog = string
    name    = string
    comment = optional(string, "")
    readers = optional(list(string), [])
    tags    = optional(map(string), {})
  }))
}

variable "compute_policies" {
  description = "Names of platform compute policies this project may use (for example ds-large-memory)."
  type        = list(string)
  default     = []
}

variable "sandbox_catalogs" {
  description = "Catalogs where people can write directly. Everywhere else only the deploy service principal writes."
  type        = list(string)
  default     = ["dev", "data_science"]
}
