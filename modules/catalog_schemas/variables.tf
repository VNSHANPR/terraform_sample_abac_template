variable "catalog_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "comment" {
  type    = string
  default = ""
}

variable "schemas" {
  type        = map(string)
  description = "Map of schema_name => comment."
}
