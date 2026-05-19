# ABAC on Databricks Unity Catalog — Terraform reference

A Terraform-first, a reference for **Attribute-Based Access Control**
on Databricks Unity Catalog

This is provided as a sample for understanding the terraform resources for databricks ABAC and is not an official documentation or best practice document. Please follow the official Terraform documentation below for more details : 


**Note : Please always use the guidance from databricks Terraform resources 

https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/policy_info

Databricks Porvider : https://registry.terraform.io/providers/databricks/databricks/latest/docs 

It provisions:

- A Unity Catalog `tritium_demo_abac` with 4 business schemas + 1 governance schema
- 11 tables modelled after Tritium's business (chargers, sites, telemetry,
  maintenance, B2B customers, drivers, sessions, payments, alarms, tariffs,
  invoices), seeded with sample data
- 7 SQL masking UDFs (`mask_email`, `mask_full_name`, `mask_phone`,
  `mask_address`, `mask_vehicle_id`, `mask_payment`, `mask_geo`)
- 2 governed tags: `data_classification` and `pii_type`
- ~25 column-level tag assignments
- 2 demo groups: `tritium_pii_full_access`, `tritium_field_service_ops`
- 7 **ABAC column-mask policies** — one per `pii_type` value, attached
  catalog-wide, so masking is tag-driven rather than table-by-table

See [`docs/architecture.md`](./docs/architecture.md) for diagrams and
[`docs/demo_script.md`](./docs/demo_script.md) for the customer walkthrough.

## Why this layout

Once a column is tagged `pii_type=email`, the `tritium_mask_email` policy applies automatically —
no per-table policy, no view, no application change. Adding a new sensitive
column next month is a one-line tag assignment.

The Terraform code mirrors that idea: tags and policies live in their own
modules and the column-to-tag mapping is a single `for_each` map in
`modules/governed_tags/assignments.tf`. Reviewers read one file to audit
the entire PII surface.

## Resource map

| Module | Resources |
|---|---|
| `modules/catalog_schemas` | `databricks_catalog`, `databricks_schema` |
| `modules/tables` | `databricks_sql_table` × 11, seed via `null_resource` + SQL Statements API |
| `modules/groups` | `databricks_group`, `databricks_group_member`, `data.databricks_user` |
| `modules/masking_functions` | `databricks_schema` (`_governance`), `null_resource` running `CREATE OR REPLACE FUNCTION` × 7 |
| `modules/governed_tags` | `databricks_tag_policy` × 2, `databricks_entity_tag_assignment` × ~25 |
| `modules/abac_policies` | `databricks_policy_info` (`POLICY_TYPE_COLUMN_MASK`) × 7, `databricks_grants` |



> **Why `null_resource` for UDFs and seed data?** Unity Catalog SQL UDFs and
> arbitrary `INSERT`s are not yet first-class Terraform resources. We use
> `null_resource` with `local-exec` calling the Databricks **SQL Statements
> API** (`/api/2.0/sql/statements`) via the `databricks` CLI. This is the
> sanctioned pattern in the provider's own examples and is idempotent: UDFs
> use `CREATE OR REPLACE`, seed inserts pre-check `COUNT(*) = 0`.

** Note : This is a workaround that we have used at the time of writing, kindly keep looking for updates in the Terraform provider link or be in rouch with the Account team that can bring more updates on the use of other way to create UDF's.

## Prerequisites

1. Terraform ≥ 1.5
2. Databricks CLI (`databricks --version` ≥ 0.230)
3. A configured Databricks CLI profile pointing at your workspace
   ```bash
   databricks auth login --host https://e2-demo-field-eng.cloud.databricks.com \
     --profile e2-demo-field-eng
   ```
4. A running SQL warehouse (any size) — note its ID
5. `jq` and `python3` on the machine running `terraform apply`
6. Permission to create catalogs and ABAC policies on the workspace
   (metastore admin or owner of the parent metastore)

## Deploy

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars — set warehouse_id, demo_user_*, owner_email

terraform init
terraform plan
terraform apply
```

First apply takes ~3 minutes. Most of the wall-clock time is the `null_resource`
calls hitting the SQL Statements API to create UDFs and seed rows.


## Tear down

```bash
terraform destroy
```

Drops the catalog, schemas, tables, tags, policies, and groups in one shot.

## Provider compatibility

Tested against `databricks/databricks` provider **v1.115.0** (May 2026). The
key resources used:

- `databricks_tag_policy` — GA since v1.88.0
- `databricks_entity_tag_assignment` — GA since v1.88.0
- `databricks_policy_info` — Public Preview, available in current provider

If `databricks_policy_info` is not available in your provider build, upgrade:

```hcl
required_providers {
  databricks = {
    source  = "databricks/databricks"
    version = ">= 1.88.0"
  }
}
```


## Layout

```
.
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── terraform.tfvars.example
├── docs/
│   ├── architecture.md     ← Mermaid diagrams
│   ├── data_model.md       ← Schema + PII surface
│   └── demo_script.md      ← Customer walkthrough
└── modules/
    ├── catalog_schemas/
    ├── tables/
    ├── groups/
    ├── masking_functions/
    ├── governed_tags/
    └── abac_policies/
```
