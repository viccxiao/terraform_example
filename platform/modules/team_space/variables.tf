variable "team" {
  description = "Team or project name, used for naming the deploy service principal."
  type        = string
}

variable "owners_group" {
  description = "Existing account group for the team's humans."
  type        = string
}

variable "schemas" {
  description = "Schemas this team owns. Readers get SELECT only."
  type = list(object({
    catalog = string
    name    = string
    comment = optional(string, "")
    readers = optional(list(string), [])
    tags    = optional(map(string), {})
  }))
}

variable "compute_policies" {
  description = "Names of platform compute policies this team may use (for example ds-large-memory)."
  type        = list(string)
  default     = []
}

variable "sandbox_catalogs" {
  description = "Catalogs where the team's humans can write directly. Everywhere else only the deploy service principal writes."
  type        = list(string)
  default     = ["dev", "data_science"]
}
