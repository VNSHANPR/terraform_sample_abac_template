locals {
  # Each map entry => one INSERT statement. Stays under the 50KB/statement API cap
  # and lets us re-run individual seeds idempotently via NOT EXISTS pre-check.
  seed_inserts = {
    b2b_customers = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["customers"]}.b2b_customers VALUES
        ('CUST-001','Highway Power Networks','PUBLIC_NETWORK','Alice Chen','alice.chen@hpn.example','+1-415-555-0142','100 Battery St','San Francisco','USA','PLATINUM',DATE'2023-06-01'),
        ('CUST-002','PortLink Logistics','FLEET','Marco Silva','marco.silva@portlink.example','+1-310-555-0118','77 Harbor Way','Long Beach','USA','GOLD',DATE'2024-01-15'),
        ('CUST-003','GreenStop Retail','RETAIL','Priya Rao','priya.rao@greenstop.example','+44-20-7946-0991','12 Camden High St','London','GBR','SILVER',DATE'2024-09-10')
    SQL

    sites = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["assets"]}.sites VALUES
        ('SITE-100','CUST-001','HPN-I80-Truckee','12000 I-80 Frontage Rd','Truckee','CA','USA',39.3280,-120.1833,'America/Los_Angeles',DATE'2023-08-12'),
        ('SITE-200','CUST-002','PortLink-LongBeach Depot','2400 Pier J Ave','Long Beach','CA','USA',33.7470,-118.2200,'America/Los_Angeles',DATE'2024-03-04'),
        ('SITE-300','CUST-003','GreenStop-Camden','12 Camden High St','London','ENG','GBR',51.5390,-0.1426,'Europe/London',DATE'2024-11-22')
    SQL

    chargers = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["assets"]}.chargers VALUES
        ('CHG-A001','SITE-100','TRI-FLEX','TF-0001-AU',400,4,'2.7.1',DATE'2023-07-01',DATE'2023-08-12',DATE'2028-08-12','OPERATIONAL'),
        ('CHG-A002','SITE-100','TRI-FLEX','TF-0002-AU',400,4,'2.7.0',DATE'2023-07-01',DATE'2023-08-12',DATE'2028-08-12','DEGRADED'),
        ('CHG-B001','SITE-200','PKM150','PK-2401-AU',150,1,'1.9.4',DATE'2024-02-20',DATE'2024-03-04',DATE'2029-03-04','OPERATIONAL'),
        ('CHG-C001','SITE-300','RTM75','RT-2411-AU',75,1,'1.6.2',DATE'2024-10-15',DATE'2024-11-22',DATE'2029-11-22','OPERATIONAL')
    SQL

    charger_telemetry = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["assets"]}.charger_telemetry VALUES
        ('CHG-A001',TIMESTAMP'2026-05-18 09:00:00',345.6,42.1,808.0,427.0,0.42,NULL,'Charging'),
        ('CHG-A001',TIMESTAMP'2026-05-18 09:05:00',312.2,43.5,807.5,386.5,0.61,NULL,'Charging'),
        ('CHG-A002',TIMESTAMP'2026-05-18 09:00:00',0.0,55.7,800.0,0.0,0.00,'E_THERMAL_DERATE','SuspendedEV'),
        ('CHG-B001',TIMESTAMP'2026-05-18 09:00:00',148.4,38.0,400.0,371.0,0.55,NULL,'Charging'),
        ('CHG-C001',TIMESTAMP'2026-05-18 09:00:00',71.2,30.2,400.0,178.0,0.30,NULL,'Charging')
    SQL

    maintenance_events = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["assets"]}.maintenance_events VALUES
        ('MNT-0001','CHG-A002','CORRECTIVE',TIMESTAMP'2026-05-15 08:00:00',TIMESTAMP'2026-05-15 11:30:00','Devon Walker','devon.walker@tritium.example','Replaced thermal sensor cable harness; cleared E_THERMAL_DERATE.','THERMAL_HARNESS_V2',412.50),
        ('MNT-0002','CHG-B001','PREVENTATIVE',TIMESTAMP'2026-04-22 14:00:00',TIMESTAMP'2026-04-22 15:15:00','Lin Zhao','lin.zhao@tritium.example','Quarterly cooling-loop inspection.','',180.00)
    SQL

    drivers = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["customers"]}.drivers VALUES
        ('DRV-100001','CUST-001','Jordan Smith','jordan.smith@example.com','+1-415-555-0190','455 Mission St, San Francisco, CA','1HGCM82633A123456','7ABC123','tok_4f9d12c1a3b8','4242',DATE'2024-04-12'),
        ('DRV-100002','CUST-001','Emily Brown','emily.brown@example.com','+1-650-555-0177','22 Embarcadero, San Francisco, CA','5YJ3E1EA7JF000316','EM2L1Y','tok_8b21c0e7d29a','1881',DATE'2024-07-30'),
        ('DRV-200001','CUST-002','Kenji Tanaka','kenji.tanaka@example.com','+1-310-555-0211','9 Pier J Ave, Long Beach, CA','3CZRM4H59FG700225','PORT01','tok_2c91d4a7b110','7811',DATE'2025-02-09')
    SQL

    tariffs = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["billing"]}.tariffs VALUES
        ('TRF-001','CUST-001','HPN Highway Standard',0.4900,0.4000,1.00,'USD',DATE'2024-01-01',DATE'2099-01-01'),
        ('TRF-002','CUST-002','PortLink Fleet Bulk',0.2900,0.0000,0.00,'USD',DATE'2024-01-01',DATE'2099-01-01'),
        ('TRF-003','CUST-003','GreenStop Retail',0.4500,0.5000,0.50,'GBP',DATE'2024-09-01',DATE'2099-01-01')
    SQL

    charging_sessions = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["operations"]}.charging_sessions VALUES
        ('SES-0000001','CHG-A001','DRV-100001',TIMESTAMP'2026-05-18 08:50:00',TIMESTAMP'2026-05-18 09:18:00',42.8,348.0,0,'COMPLETED','TRF-001'),
        ('SES-0000002','CHG-A001','DRV-100002',TIMESTAMP'2026-05-18 09:22:00',TIMESTAMP'2026-05-18 09:55:00',38.1,322.5,4,'COMPLETED','TRF-001'),
        ('SES-0000003','CHG-B001','DRV-200001',TIMESTAMP'2026-05-18 08:30:00',TIMESTAMP'2026-05-18 10:05:00',128.7,150.0,0,'COMPLETED','TRF-002'),
        ('SES-0000004','CHG-A002','DRV-100001',TIMESTAMP'2026-05-18 07:10:00',TIMESTAMP'2026-05-18 07:14:00',0.4,3.1,0,'FAULTED','TRF-001')
    SQL

    session_payments = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["operations"]}.session_payments VALUES
        ('PAY-0000001','SES-0000001',20.97,'USD','tok_4f9d12c1a3b8','4242','CAPTURED',TIMESTAMP'2026-05-18 09:18:30'),
        ('PAY-0000002','SES-0000002',18.67,'USD','tok_8b21c0e7d29a','1881','CAPTURED',TIMESTAMP'2026-05-18 09:55:30'),
        ('PAY-0000003','SES-0000003',37.32,'USD','tok_2c91d4a7b110','7811','CAPTURED',TIMESTAMP'2026-05-18 10:05:30'),
        ('PAY-0000004','SES-0000004',0.00,'USD','tok_4f9d12c1a3b8','4242','FAILED',TIMESTAMP'2026-05-18 07:14:30')
    SQL

    alarms = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["operations"]}.alarms VALUES
        ('ALM-0001','CHG-A002',TIMESTAMP'2026-05-15 07:55:00','MAJOR','THERMAL','E_THERMAL_DERATE: liquid loop temperature 55C, derating to 0 kW','devon.walker',TIMESTAMP'2026-05-15 08:02:00'),
        ('ALM-0002','CHG-B001',TIMESTAMP'2026-04-22 13:55:00','INFO','UI','Scheduled preventative maintenance window opened','lin.zhao',TIMESTAMP'2026-04-22 14:00:00')
    SQL

    invoices = <<-SQL
      INSERT INTO ${var.catalog_name}.${var.schemas["billing"]}.invoices VALUES
        ('INV-2026-04-001','CUST-001',DATE'2026-04-01',DATE'2026-04-30',12480.55,'USD','PAID','ap@hpn.example',DATE'2026-05-01'),
        ('INV-2026-04-002','CUST-002',DATE'2026-04-01',DATE'2026-04-30',38927.10,'USD','SENT','finance@portlink.example',DATE'2026-05-01'),
        ('INV-2026-04-003','CUST-003',DATE'2026-04-01',DATE'2026-04-30',2154.40,'GBP','DRAFT','billing@greenstop.example',DATE'2026-05-01')
    SQL
  }

  # Each table => target fqn used by the idempotency guard (only seed if empty).
  seed_targets = {
    b2b_customers      = "${var.catalog_name}.${var.schemas["customers"]}.b2b_customers"
    sites              = "${var.catalog_name}.${var.schemas["assets"]}.sites"
    chargers           = "${var.catalog_name}.${var.schemas["assets"]}.chargers"
    charger_telemetry  = "${var.catalog_name}.${var.schemas["assets"]}.charger_telemetry"
    maintenance_events = "${var.catalog_name}.${var.schemas["assets"]}.maintenance_events"
    drivers            = "${var.catalog_name}.${var.schemas["customers"]}.drivers"
    tariffs            = "${var.catalog_name}.${var.schemas["billing"]}.tariffs"
    charging_sessions  = "${var.catalog_name}.${var.schemas["operations"]}.charging_sessions"
    session_payments   = "${var.catalog_name}.${var.schemas["operations"]}.session_payments"
    alarms             = "${var.catalog_name}.${var.schemas["operations"]}.alarms"
    invoices           = "${var.catalog_name}.${var.schemas["billing"]}.invoices"
  }
}

# Uses the Databricks CLI ( https://docs.databricks.com/dev-tools/cli ) which
# must be available on the machine running terraform apply. We hit the
# Statements API rather than asking the customer to install pyodbc/JDBC.
resource "null_resource" "seed" {
  for_each = var.seed_data ? local.seed_inserts : {}

  triggers = {
    table_fqn = local.seed_targets[each.key]
    sql_hash  = sha256(each.value)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-CMD
      set -euo pipefail
      WAREHOUSE_ID="${var.warehouse_id}"
      TARGET="${local.seed_targets[each.key]}"
      PROFILE="${var.cli_profile}"

      COUNT=$(databricks api post /api/2.0/sql/statements --profile "$PROFILE" \
        --json '{"warehouse_id":"'"$WAREHOUSE_ID"'","statement":"SELECT COUNT(*) AS c FROM '"$TARGET"'","wait_timeout":"30s"}' \
        | python3 -c 'import sys,json; r=json.load(sys.stdin); print(r["result"]["data_array"][0][0])')

      if [ "$COUNT" -gt 0 ]; then
        echo "Seed skipped for $TARGET (rows=$COUNT)."
        exit 0
      fi

      databricks api post /api/2.0/sql/statements --profile "$PROFILE" \
        --json "$(jq -nc --arg w "$WAREHOUSE_ID" --arg s "${replace(replace(each.value, "\\", "\\\\"), "\"", "\\\"")}" \
                  '{warehouse_id:$w, statement:$s, wait_timeout:"30s"}')"
      echo "Seeded $TARGET."
    CMD
  }

  depends_on = [
    databricks_sql_table.b2b_customers,
    databricks_sql_table.drivers,
    databricks_sql_table.sites,
    databricks_sql_table.chargers,
    databricks_sql_table.charger_telemetry,
    databricks_sql_table.maintenance_events,
    databricks_sql_table.charging_sessions,
    databricks_sql_table.session_payments,
    databricks_sql_table.alarms,
    databricks_sql_table.tariffs,
    databricks_sql_table.invoices,
  ]
}
