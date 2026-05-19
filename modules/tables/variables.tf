variable "catalog_name" {
  type = string
}

variable "schemas" {
  type        = map(string)
  description = "Map of logical schema => actual schema name."
}

variable "warehouse_id" {
  type        = string
  description = "SQL warehouse used to seed sample data via databricks_sql_permissions / SQL provisioner."
}

variable "cli_profile" {
  type        = string
  description = "Databricks CLI profile passed to local-exec calls (so they don't fall back to OAuth)."
}

variable "seed_data" {
  type    = bool
  default = true
}
