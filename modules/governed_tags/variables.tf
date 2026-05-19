variable "catalog_name" {
  type = string
}

variable "schemas" {
  type        = map(string)
  description = "Map of logical schema => actual schema name."
}

variable "tag_prefix" {
  type        = string
  description = "Prefix for governed tag keys (e.g. \"tritium_\" -> tritium_pii_type)."
  default     = "tritium_"
}
