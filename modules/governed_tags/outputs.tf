# Map from logical PII category => the actual tag key in use.
# The abac_policies module consumes this so policy conditions and policy names
# stay in sync with whatever keys this module decides to use (currently the
# pre-existing `class.*` system tags).
output "tag_keys" {
  value = {
    email         = "class.email_address"
    full_name     = "class.name"
    phone         = "class.phone_number"
    address       = "class.location"
    vehicle_vin   = "class.vin"
    license_plate = "class.license_plate"
    payment       = "class.credit_card"
  }
}

output "pii_columns" {
  value = local.pii_columns
}
