variable "catalog_name" {
  type = string
}

variable "masking_functions" {
  type        = map(string)
  description = "Map of function short name => fully qualified UDF name from masking_functions module."
}

variable "field_service_grp" {
  type        = string
  description = "Group display name (or user email) that receives masked PII. NOTE: ABAC requires account-scope identities. In this demo we pass a user email because the workspace-token provider can only create workspace-local groups. In production use an account-scope group display name here."
}

variable "pii_full_grp" {
  type        = string
  description = "Group display name (or user email) that bypasses masking. Same caveat as field_service_grp."
}

variable "tag_keys" {
  type        = map(string)
  description = "Logical PII category => the governed tag key in use (from governed_tags module)."
}

variable "policy_name_prefix" {
  type        = string
  description = "Prefix applied to each databricks_policy_info name to keep them unique in a shared metastore."
  default     = "tritium_"
}
