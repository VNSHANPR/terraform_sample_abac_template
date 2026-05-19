output "catalog_name" {
  value = databricks_catalog.this.name
}

output "schema_names" {
  value = { for k, v in databricks_schema.this : k => v.name }
}

output "schema_fqns" {
  value = { for k, v in databricks_schema.this : k => "${databricks_catalog.this.name}.${v.name}" }
}
