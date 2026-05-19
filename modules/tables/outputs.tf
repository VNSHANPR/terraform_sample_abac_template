output "table_fqns" {
  value = {
    sites              = "${var.catalog_name}.${var.schemas["assets"]}.sites"
    chargers           = "${var.catalog_name}.${var.schemas["assets"]}.chargers"
    charger_telemetry  = "${var.catalog_name}.${var.schemas["assets"]}.charger_telemetry"
    maintenance_events = "${var.catalog_name}.${var.schemas["assets"]}.maintenance_events"
    b2b_customers      = "${var.catalog_name}.${var.schemas["customers"]}.b2b_customers"
    drivers            = "${var.catalog_name}.${var.schemas["customers"]}.drivers"
    charging_sessions  = "${var.catalog_name}.${var.schemas["operations"]}.charging_sessions"
    session_payments   = "${var.catalog_name}.${var.schemas["operations"]}.session_payments"
    alarms             = "${var.catalog_name}.${var.schemas["operations"]}.alarms"
    tariffs            = "${var.catalog_name}.${var.schemas["billing"]}.tariffs"
    invoices           = "${var.catalog_name}.${var.schemas["billing"]}.invoices"
  }
}
