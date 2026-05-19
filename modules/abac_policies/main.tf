# ABAC pattern in this demo
#
#   For each PII category we attach ONE catalog-scoped column-mask policy.
#   The policy matches columns by `hasTag(<key>)` — presence of the
#   pre-existing `class.*` system tag is enough; no value is required.
#
#   * Condition:
#       - applies to ALL principals (`account users`)
#       - EXCEPT the tritium_pii_full_access group (governance bypass)
#       - matches any column carrying the tag
#   * Action:
#       - call the matching masking UDF (mask_email, mask_full_name, …)
#
#   Because the policy is *attribute-driven*, tagging a new column with the
#   same key automatically inherits the masking — zero new policies needed.

locals {
  # logical category => { tag key (from governed_tags output), masking UDF }
  policy_map = {
    email = {
      tag  = var.tag_keys["email"]
      func = "mask_email"
    }
    full_name = {
      tag  = var.tag_keys["full_name"]
      func = "mask_full_name"
    }
    phone = {
      tag  = var.tag_keys["phone"]
      func = "mask_phone"
    }
    address = {
      tag  = var.tag_keys["address"]
      func = "mask_address"
    }
    vehicle_vin = {
      tag  = var.tag_keys["vehicle_vin"]
      func = "mask_vehicle_id"
    }
    license_plate = {
      tag  = var.tag_keys["license_plate"]
      func = "mask_vehicle_id"
    }
    payment = {
      tag  = var.tag_keys["payment"]
      func = "mask_payment"
    }
  }
}

resource "databricks_policy_info" "column_mask" {
  for_each = local.policy_map

  on_securable_type     = "CATALOG"
  on_securable_fullname = var.catalog_name
  name                  = "${var.policy_name_prefix}mask_${each.key}"
  comment               = "Mask columns tagged ${each.value.tag} for everyone except ${var.pii_full_grp}."

  policy_type        = "POLICY_TYPE_COLUMN_MASK"
  for_securable_type = "TABLE"

  to_principals     = ["account users"]
  except_principals = [var.pii_full_grp]

  # Apply whenever any column on a table carries the matching tag key.
  when_condition = "hasTag('${each.value.tag}')"

  match_columns = [
    {
      condition = "hasTag('${each.value.tag}')"
      alias     = "target_col"
    }
  ]

  column_mask = {
    function_name = var.masking_functions[each.value.func]
    on_column     = "target_col"
  }
}

# Catalog-level read grants so the demo personas can actually SELECT.
resource "databricks_grants" "catalog_reads" {
  catalog = var.catalog_name

  grant {
    principal  = var.field_service_grp
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT", "EXECUTE"]
  }

  grant {
    principal  = var.pii_full_grp
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT", "EXECUTE"]
  }
}
