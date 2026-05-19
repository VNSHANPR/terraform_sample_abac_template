# Governance / privacy office. Full unmasked view of PII for audit.
resource "databricks_group" "pii_full_access" {
  display_name = "tritium_pii_full_access"
}

# Primary demo persona. Field service / operations engineers — they need
# device, telemetry, and alarm data to fix chargers, but never see customer
# PII or payment info.
resource "databricks_group" "field_service_ops" {
  display_name = "tritium_field_service_ops"
}

data "databricks_user" "pii_full" {
  user_name = var.demo_user_pii_full
}

data "databricks_user" "field_service" {
  user_name = var.demo_user_field_service
}

resource "databricks_group_member" "pii_full_member" {
  group_id  = databricks_group.pii_full_access.id
  member_id = data.databricks_user.pii_full.id
}

resource "databricks_group_member" "field_service_member" {
  group_id  = databricks_group.field_service_ops.id
  member_id = data.databricks_user.field_service.id
}
