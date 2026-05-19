# Dedicated governance schema so masking UDFs aren't intermingled with data.
resource "databricks_schema" "governance" {
  catalog_name  = var.catalog_name
  name          = var.functions_schema
  comment       = "Masking UDFs and other governance helpers."
  force_destroy = true # demo schema — cascade UDF cleanup on destroy
}

locals {
  fns = {
    mask_email = {
      args = "v STRING"
      ret  = "STRING"
      body = "CASE WHEN v IS NULL THEN NULL WHEN instr(v, '@') = 0 THEN '***' ELSE concat('***@', split(v, '@')[1]) END"
      doc  = "Returns ***@domain.tld; preserves the domain so analytics on email-domain still works."
    }
    mask_full_name = {
      args = "v STRING"
      ret  = "STRING"
      body = "CASE WHEN v IS NULL OR length(v) = 0 THEN NULL ELSE concat(substr(v, 1, 1), repeat('*', greatest(length(v) - 1, 1))) END"
      doc  = "Keeps the first character only. Example Jordan Smith becomes J***********."
    }
    mask_phone = {
      args = "v STRING"
      ret  = "STRING"
      body = "CASE WHEN v IS NULL THEN NULL ELSE concat('***-***-', right(regexp_replace(v, '[^0-9]', ''), 4)) END"
      doc  = "Keeps the last 4 digits. Example +1-415-555-0142 becomes ***-***-0142."
    }
    mask_address = {
      args = "v STRING"
      ret  = "STRING"
      body = "CASE WHEN v IS NULL THEN NULL ELSE '[REDACTED]' END"
      doc  = "Address is fully redacted."
    }
    mask_vehicle_id = {
      args = "v STRING"
      ret  = "STRING"
      body = "CASE WHEN v IS NULL OR length(v) < 4 THEN '****' ELSE concat(substr(v, 1, 3), repeat('*', length(v) - 3)) END"
      doc  = "Preserves first 3 chars (WMI for VIN, region for plate)."
    }
    mask_payment = {
      args = "v STRING"
      ret  = "STRING"
      body = "CASE WHEN v IS NULL THEN NULL ELSE '****' END"
      doc  = "Payment tokens and card last-4 are fully redacted."
    }
    mask_geo = {
      args = "v DOUBLE"
      ret  = "DOUBLE"
      body = "CASE WHEN v IS NULL THEN NULL ELSE round(v, 1) END"
      doc  = "Rounds lat/lon to 1 decimal (~11 km) — preserves regional analytics."
    }
  }
}

resource "null_resource" "create_function" {
  for_each = local.fns

  triggers = {
    fqn  = "${var.catalog_name}.${var.functions_schema}.${each.key}"
    body = sha256("${each.value.args}|${each.value.ret}|${each.value.body}|${each.value.doc}")
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-CMD
      set -euo pipefail
      databricks api post /api/2.0/sql/statements --profile '${var.cli_profile}' \
        --json "$(jq -nc --arg w '${var.warehouse_id}' --arg s ${format("%q", "CREATE OR REPLACE FUNCTION ${var.catalog_name}.${var.functions_schema}.${each.key}(${each.value.args}) RETURNS ${each.value.ret} COMMENT '${each.value.doc}' RETURN ${each.value.body}")} \
                '{warehouse_id:$w, statement:$s, wait_timeout:"30s"}')"
      echo "Created ${var.catalog_name}.${var.functions_schema}.${each.key}"
    CMD
  }

  depends_on = [databricks_schema.governance]
}
