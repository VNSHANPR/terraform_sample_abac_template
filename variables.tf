variable "workspace_host" {
  type        = string
  description = "Databricks workspace URL."
  default     = ""
}

variable "databricks_cli_profile" {
  type        = string
  description = "Local databricks-cli profile used for authentication. Must exist in ~/.databrickscfg."
  default     = ""
}

variable "owner_email" {
  type        = string
  description = "Email of the catalog/schema owner principal (a user or service principal)."
  default     = ""
}

variable "catalog_name" {
  type        = string
  description = "Top-level UC catalog created for this demo."
  default     = ""
}

variable "tag_prefix" {
  type        = string
  description = "Prefix applied to all governed tag keys to keep them unique in a shared metastore. Final keys: <prefix>data_classification, <prefix>pii_type."
  default     = ""
}

variable "warehouse_id" {
  type        = string
  description = "SQL warehouse ID used to execute SQL UDF and seed-data statements."
  default     = "" # 
}

variable "seed_data" {
  type        = bool
  description = "If true, insert a small set of sample rows into each table so the demo SELECTs return masked vs unmasked output immediately."
  default     = true
}

variable "demo_user_pii_full" {
  type        = string
  description = "Email of the demo user added to tritium_pii_full_access. Sees raw values."
  default     = ""
}

variable "demo_user_field_service" {
  type        = string
  description = "Email of the demo user added to tritium_field_service_ops. Sees masked PII."
  default     = ""
}
