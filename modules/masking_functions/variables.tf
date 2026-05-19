variable "catalog_name" {
  type = string
}

variable "warehouse_id" {
  type = string
}

variable "cli_profile" {
  type        = string
  description = "Databricks CLI profile passed to local-exec (so it doesn't fall back to OAuth)."
}

variable "functions_schema" {
  type        = string
  description = "Schema where the masking UDFs live."
  default     = "_governance"
}
