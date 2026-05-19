variable "demo_user_pii_full" {
  type        = string
  description = "Email of an existing workspace user added to tritium_pii_full_access (sees raw PII)."
}

variable "demo_user_field_service" {
  type        = string
  description = "Email of an existing workspace user added to tritium_field_service_ops (sees masked PII)."
}
