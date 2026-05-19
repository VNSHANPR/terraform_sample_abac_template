locals {
  catalog = var.catalog_name

  schemas = {
    assets     = "Charging hardware: chargers, sites, telemetry, maintenance."
    operations = "Charging sessions, alarms, session payments."
    customers  = "B2B network operators and end-driver accounts."
    billing    = "Tariffs, invoices, revenue."
  }
}

module "catalog_schemas" {
  source       = "./modules/catalog_schemas"
  catalog_name = local.catalog
  owner        = var.owner_email
  schemas      = local.schemas
  comment      = "Tritium Charging ABAC demo catalog."
}

module "tables" {
  source       = "./modules/tables"
  catalog_name = module.catalog_schemas.catalog_name
  schemas      = module.catalog_schemas.schema_names
  warehouse_id = var.warehouse_id
  cli_profile  = var.databricks_cli_profile
  seed_data    = var.seed_data
}

module "groups" {
  source                  = "./modules/groups"
  demo_user_pii_full      = var.demo_user_pii_full
  demo_user_field_service = var.demo_user_field_service
}

module "governed_tags" {
  source       = "./modules/governed_tags"
  catalog_name = module.catalog_schemas.catalog_name
  schemas      = module.catalog_schemas.schema_names
  tag_prefix   = var.tag_prefix
  depends_on   = [module.tables]
}

module "masking_functions" {
  source       = "./modules/masking_functions"
  catalog_name = module.catalog_schemas.catalog_name
  warehouse_id = var.warehouse_id
  cli_profile  = var.databricks_cli_profile
  depends_on   = [module.catalog_schemas]
}

module "abac_policies" {
  source            = "./modules/abac_policies"
  catalog_name      = module.catalog_schemas.catalog_name
  masking_functions = module.masking_functions.function_fqns
  # Pass demo user emails directly: ABAC API needs account-scope identities,
  # and workspace-token TF can't create account groups. The workspace-local
  # groups module still creates the groups for the data model story, but the
  # ABAC enforcement principals are the individual users.
  field_service_grp  = var.demo_user_field_service
  pii_full_grp       = var.demo_user_pii_full
  tag_keys           = module.governed_tags.tag_keys
  policy_name_prefix = var.tag_prefix
  depends_on         = [module.governed_tags, module.masking_functions]
}
