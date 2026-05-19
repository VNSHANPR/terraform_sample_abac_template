output "policy_names" {
  value = { for k, v in databricks_policy_info.column_mask : k => v.name }
}
