output "function_fqns" {
  value = { for k, _ in {
    mask_email      = ""
    mask_full_name  = ""
    mask_phone      = ""
    mask_address    = ""
    mask_vehicle_id = ""
    mask_payment    = ""
    mask_geo        = ""
  } : k => "${var.catalog_name}.${var.functions_schema}.${k}" }
}

output "functions_schema" {
  value = databricks_schema.governance.name
}
