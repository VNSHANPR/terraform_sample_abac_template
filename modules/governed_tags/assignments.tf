locals {
  cat          = var.catalog_name
  s_assets     = var.schemas["assets"]
  s_customers  = var.schemas["customers"]
  s_operations = var.schemas["operations"]
  s_billing    = var.schemas["billing"]

  # Existing system tag keys re-used by this demo. These exist in the
  # E2-Demo-Field-Eng metastore as built-in `class.*` policies. Each is a
  # presence-only marker — the ABAC policy condition is `hasTag(<key>)`.
  tag_email         = "class.email_address"
  tag_name          = "class.name"
  tag_phone         = "class.phone_number"
  tag_address       = "class.location"
  tag_vin           = "class.vin"
  tag_license_plate = "class.license_plate"
  tag_payment       = "class.credit_card"

  # column FQN => existing class.* key
  # Every line in this map is one PII column on this catalog. Add a new
  # sensitive column here and the ABAC policy for that class.* key picks
  # it up automatically — no new policy needed.
  pii_columns = {
    # B2B customers
    "${local.cat}.${local.s_customers}.b2b_customers.primary_contact_name"  = local.tag_name
    "${local.cat}.${local.s_customers}.b2b_customers.primary_contact_email" = local.tag_email
    "${local.cat}.${local.s_customers}.b2b_customers.primary_contact_phone" = local.tag_phone
    "${local.cat}.${local.s_customers}.b2b_customers.billing_street"        = local.tag_address

    # Drivers
    "${local.cat}.${local.s_customers}.drivers.full_name"     = local.tag_name
    "${local.cat}.${local.s_customers}.drivers.email"         = local.tag_email
    "${local.cat}.${local.s_customers}.drivers.phone"         = local.tag_phone
    "${local.cat}.${local.s_customers}.drivers.home_address"  = local.tag_address
    "${local.cat}.${local.s_customers}.drivers.vehicle_vin"   = local.tag_vin
    "${local.cat}.${local.s_customers}.drivers.license_plate" = local.tag_license_plate
    "${local.cat}.${local.s_customers}.drivers.payment_token" = local.tag_payment
    "${local.cat}.${local.s_customers}.drivers.card_last4"    = local.tag_payment

    # Maintenance — internal technician contact info is still PII.
    "${local.cat}.${local.s_assets}.maintenance_events.technician_name"  = local.tag_name
    "${local.cat}.${local.s_assets}.maintenance_events.technician_email" = local.tag_email

    # Sites — street address only (lat/lon left untagged to keep class.location
    # mapped 1:1 with mask_address in this demo).
    "${local.cat}.${local.s_assets}.sites.street_address" = local.tag_address

    # Session payments
    "${local.cat}.${local.s_operations}.session_payments.payment_token" = local.tag_payment
    "${local.cat}.${local.s_operations}.session_payments.card_last4"    = local.tag_payment

    # Billing
    "${local.cat}.${local.s_billing}.invoices.billing_contact_email" = local.tag_email
  }
}

resource "databricks_entity_tag_assignment" "pii" {
  for_each = local.pii_columns

  entity_type = "columns"
  entity_name = each.key
  tag_key     = each.value
  # class.* system tags are presence-only. The API returns an empty-string
  # value even when none is set, so we declare it explicitly to avoid the
  # "Provider produced inconsistent result" error.
  tag_value = ""
}
