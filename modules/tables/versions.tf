terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.88.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
