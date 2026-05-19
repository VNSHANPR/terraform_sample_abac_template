locals {
  cat = var.catalog_name
}

############################################
# assets schema
############################################

resource "databricks_sql_table" "sites" {
  catalog_name = local.cat
  schema_name  = var.schemas["assets"]
  name         = "sites"
  table_type   = "MANAGED"
  comment      = "Customer-operated charging sites (depots, highway plazas, retail). Owned by a B2B customer."

  column {
    name     = "site_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "customer_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "site_name"
    type = "STRING"
  }
  column {
    name    = "street_address"
    type    = "STRING"
    comment = "PII (address)"
  }
  column {
    name = "city"
    type = "STRING"
  }
  column {
    name = "state_region"
    type = "STRING"
  }
  column {
    name = "country"
    type = "STRING"
  }
  column {
    name    = "latitude"
    type    = "DOUBLE"
    comment = "Precise geolocation; treat as PII."
  }
  column {
    name    = "longitude"
    type    = "DOUBLE"
    comment = "Precise geolocation; treat as PII."
  }
  column {
    name = "timezone"
    type = "STRING"
  }
  column {
    name = "commissioned_on"
    type = "DATE"
  }
}

resource "databricks_sql_table" "chargers" {
  catalog_name = local.cat
  schema_name  = var.schemas["assets"]
  name         = "chargers"
  table_type   = "MANAGED"
  comment      = "Individual DC fast chargers (RTM75, PKM150, TRI-FLEX, GRID-FLEX) deployed at a site."

  column {
    name     = "charger_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "site_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name    = "model"
    type    = "STRING"
    comment = "RTM75 | PKM150 | TRI-FLEX | GRID-FLEX"
  }
  column {
    name    = "serial_number"
    type    = "STRING"
    comment = "Hardware serial."
  }
  column {
    name = "rated_power_kw"
    type = "INT"
  }
  column {
    name = "connector_count"
    type = "INT"
  }
  column {
    name = "firmware_version"
    type = "STRING"
  }
  column {
    name = "manufactured_on"
    type = "DATE"
  }
  column {
    name = "installed_on"
    type = "DATE"
  }
  column {
    name = "warranty_end"
    type = "DATE"
  }
  column {
    name    = "status"
    type    = "STRING"
    comment = "OPERATIONAL | DEGRADED | OFFLINE | DECOMMISSIONED"
  }
}

resource "databricks_sql_table" "charger_telemetry" {
  catalog_name = local.cat
  schema_name  = var.schemas["assets"]
  name         = "charger_telemetry"
  table_type   = "MANAGED"
  comment      = "High-frequency operational telemetry from each charger."

  column {
    name     = "charger_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "ts"
    type     = "TIMESTAMP"
    nullable = false
  }
  column {
    name = "power_kw"
    type = "DOUBLE"
  }
  column {
    name = "temperature_c"
    type = "DOUBLE"
  }
  column {
    name = "voltage_v"
    type = "DOUBLE"
  }
  column {
    name = "current_a"
    type = "DOUBLE"
  }
  column {
    name = "state_of_charge"
    type = "DOUBLE"
  }
  column {
    name = "error_code"
    type = "STRING"
  }
  column {
    name = "ocpp_status"
    type = "STRING"
  }
}

resource "databricks_sql_table" "maintenance_events" {
  catalog_name = local.cat
  schema_name  = var.schemas["assets"]
  name         = "maintenance_events"
  table_type   = "MANAGED"
  comment      = "Field service / maintenance interventions on chargers."

  column {
    name     = "event_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "charger_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name    = "event_type"
    type    = "STRING"
    comment = "PREVENTATIVE | CORRECTIVE | RECALL | INSPECTION"
  }
  column {
    name = "started_at"
    type = "TIMESTAMP"
  }
  column {
    name = "ended_at"
    type = "TIMESTAMP"
  }
  column {
    name    = "technician_name"
    type    = "STRING"
    comment = "PII (full name) — internal field engineer."
  }
  column {
    name    = "technician_email"
    type    = "STRING"
    comment = "PII (email)."
  }
  column {
    name = "description"
    type = "STRING"
  }
  column {
    name = "parts_replaced"
    type = "STRING"
  }
  column {
    name = "cost_usd"
    type = "DECIMAL(12,2)"
  }
}

############################################
# customers schema
############################################

resource "databricks_sql_table" "b2b_customers" {
  catalog_name = local.cat
  schema_name  = var.schemas["customers"]
  name         = "b2b_customers"
  table_type   = "MANAGED"
  comment      = "Tritium B2B customers: charging network operators, fleet operators, retailers."

  column {
    name     = "customer_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "company_name"
    type = "STRING"
  }
  column {
    name    = "industry_segment"
    type    = "STRING"
    comment = "PUBLIC_NETWORK | FLEET | RETAIL | UTILITY | TRANSIT"
  }
  column {
    name    = "primary_contact_name"
    type    = "STRING"
    comment = "PII (full name)."
  }
  column {
    name    = "primary_contact_email"
    type    = "STRING"
    comment = "PII (email)."
  }
  column {
    name    = "primary_contact_phone"
    type    = "STRING"
    comment = "PII (phone)."
  }
  column {
    name    = "billing_street"
    type    = "STRING"
    comment = "PII (address)."
  }
  column {
    name = "billing_city"
    type = "STRING"
  }
  column {
    name = "billing_country"
    type = "STRING"
  }
  column {
    name    = "tier"
    type    = "STRING"
    comment = "PLATINUM | GOLD | SILVER | STANDARD"
  }
  column {
    name = "onboarded_on"
    type = "DATE"
  }
}

resource "databricks_sql_table" "drivers" {
  catalog_name = local.cat
  schema_name  = var.schemas["customers"]
  name         = "drivers"
  table_type   = "MANAGED"
  comment      = "End-driver accounts (via My Tritium / network operator) authorised to start sessions."

  column {
    name     = "driver_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name    = "customer_id"
    type    = "STRING"
    comment = "Network operator the driver belongs to."
  }
  column {
    name    = "full_name"
    type    = "STRING"
    comment = "PII (full name)."
  }
  column {
    name    = "email"
    type    = "STRING"
    comment = "PII (email)."
  }
  column {
    name    = "phone"
    type    = "STRING"
    comment = "PII (phone)."
  }
  column {
    name    = "home_address"
    type    = "STRING"
    comment = "PII (address)."
  }
  column {
    name    = "vehicle_vin"
    type    = "STRING"
    comment = "PII (vehicle identifier)."
  }
  column {
    name    = "license_plate"
    type    = "STRING"
    comment = "PII (vehicle identifier)."
  }
  column {
    name    = "payment_token"
    type    = "STRING"
    comment = "PII (payment) — tokenized PAN."
  }
  column {
    name    = "card_last4"
    type    = "STRING"
    comment = "PII (payment)."
  }
  column {
    name = "signup_date"
    type = "DATE"
  }
}

############################################
# operations schema
############################################

resource "databricks_sql_table" "charging_sessions" {
  catalog_name = local.cat
  schema_name  = var.schemas["operations"]
  name         = "charging_sessions"
  table_type   = "MANAGED"
  comment      = "One row per charging session (plug-in to unplug)."

  column {
    name     = "session_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "charger_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "driver_id"
    type = "STRING"
  }
  column {
    name = "start_ts"
    type = "TIMESTAMP"
  }
  column {
    name = "end_ts"
    type = "TIMESTAMP"
  }
  column {
    name = "energy_kwh"
    type = "DOUBLE"
  }
  column {
    name = "peak_kw"
    type = "DOUBLE"
  }
  column {
    name = "idle_minutes"
    type = "INT"
  }
  column {
    name    = "session_status"
    type    = "STRING"
    comment = "COMPLETED | FAULTED | ABORTED_BY_USER | TIMEOUT"
  }
  column {
    name = "tariff_id"
    type = "STRING"
  }
}

resource "databricks_sql_table" "session_payments" {
  catalog_name = local.cat
  schema_name  = var.schemas["operations"]
  name         = "session_payments"
  table_type   = "MANAGED"
  comment      = "Payment record per charging session."

  column {
    name     = "payment_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "session_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "amount"
    type = "DECIMAL(10,2)"
  }
  column {
    name = "currency"
    type = "STRING"
  }
  column {
    name    = "payment_token"
    type    = "STRING"
    comment = "PII (payment)."
  }
  column {
    name    = "card_last4"
    type    = "STRING"
    comment = "PII (payment)."
  }
  column {
    name    = "status"
    type    = "STRING"
    comment = "AUTHORIZED | CAPTURED | REFUNDED | FAILED"
  }
  column {
    name = "processed_at"
    type = "TIMESTAMP"
  }
}

resource "databricks_sql_table" "alarms" {
  catalog_name = local.cat
  schema_name  = var.schemas["operations"]
  name         = "alarms"
  table_type   = "MANAGED"
  comment      = "Alarm/event stream from chargers, surfaced to field service."

  column {
    name     = "alarm_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name     = "charger_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "ts"
    type = "TIMESTAMP"
  }
  column {
    name    = "severity"
    type    = "STRING"
    comment = "CRITICAL | MAJOR | MINOR | INFO"
  }
  column {
    name    = "category"
    type    = "STRING"
    comment = "THERMAL | POWER | COMMS | UI | SECURITY"
  }
  column {
    name = "description"
    type = "STRING"
  }
  column {
    name    = "acknowledged_by"
    type    = "STRING"
    comment = "Internal username — not customer PII."
  }
  column {
    name = "acknowledged_at"
    type = "TIMESTAMP"
  }
}

############################################
# billing schema
############################################

resource "databricks_sql_table" "tariffs" {
  catalog_name = local.cat
  schema_name  = var.schemas["billing"]
  name         = "tariffs"
  table_type   = "MANAGED"
  comment      = "Pricing plans applied to charging sessions."

  column {
    name     = "tariff_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "customer_id"
    type = "STRING"
  }
  column {
    name = "name"
    type = "STRING"
  }
  column {
    name = "base_kwh_price"
    type = "DECIMAL(6,4)"
  }
  column {
    name = "idle_fee_per_min"
    type = "DECIMAL(6,4)"
  }
  column {
    name = "session_start_fee"
    type = "DECIMAL(6,2)"
  }
  column {
    name = "currency"
    type = "STRING"
  }
  column {
    name = "effective_from"
    type = "DATE"
  }
  column {
    name = "effective_to"
    type = "DATE"
  }
}

resource "databricks_sql_table" "invoices" {
  catalog_name = local.cat
  schema_name  = var.schemas["billing"]
  name         = "invoices"
  table_type   = "MANAGED"
  comment      = "Aggregated monthly invoice per B2B customer."

  column {
    name     = "invoice_id"
    type     = "STRING"
    nullable = false
  }
  column {
    name = "customer_id"
    type = "STRING"
  }
  column {
    name = "period_start"
    type = "DATE"
  }
  column {
    name = "period_end"
    type = "DATE"
  }
  column {
    name = "total_amount"
    type = "DECIMAL(12,2)"
  }
  column {
    name = "currency"
    type = "STRING"
  }
  column {
    name    = "status"
    type    = "STRING"
    comment = "DRAFT | SENT | PAID | OVERDUE"
  }
  column {
    name    = "billing_contact_email"
    type    = "STRING"
    comment = "PII (email)."
  }
  column {
    name = "issued_on"
    type = "DATE"
  }
}
