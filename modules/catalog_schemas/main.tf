resource "databricks_catalog" "this" {
  name           = var.catalog_name
  comment        = var.comment
  owner          = var.owner
  isolation_mode = "ISOLATED"
  force_destroy  = true # demo catalog — let destroy cascade through schemas

  properties = {
    purpose = "abac-demo-tritium"
  }
}

resource "databricks_schema" "this" {
  for_each      = var.schemas
  catalog_name  = databricks_catalog.this.name
  name          = each.key
  comment       = each.value
  owner         = var.owner
  force_destroy = true # demo schema — let destroy cascade through tables
}
