# Tritium Demo — Data Model & PII Classification

Catalog: **`tritium_demo_abac`**.

## Schemas

| Schema | Purpose |
|---|---|
| `assets` | Hardware: sites, chargers, telemetry, maintenance events |
| `customers` | B2B network operators + their end drivers |
| `operations` | Charging sessions, session payments, alarms |
| `billing` | Tariffs and invoices |
| `_governance` | Masking UDFs (kept out of business schemas) |

## Tables and PII surface

Columns marked **PII** carry an `entity_tag_assignment` with `pii_type=<value>`,
which is what the ABAC column-mask policies match on.

### `assets.sites`
| Column | Type | PII tag |
|---|---|---|
| site_id | STRING | |
| customer_id | STRING | |
| site_name | STRING | |
| street_address | STRING | **address** |
| city | STRING | |
| state_region | STRING | |
| country | STRING | |
| latitude | DOUBLE | **geo_precise** |
| longitude | DOUBLE | **geo_precise** |
| timezone | STRING | |
| commissioned_on | DATE | |

### `assets.chargers`
charger_id, site_id, model (RTM75 / PKM150 / TRI-FLEX / GRID-FLEX),
serial_number, rated_power_kw, connector_count, firmware_version,
manufactured_on, installed_on, warranty_end, status. **No PII.**

### `assets.charger_telemetry`
charger_id, ts, power_kw, temperature_c, voltage_v, current_a,
state_of_charge, error_code, ocpp_status. **No PII.**

### `assets.maintenance_events`
| Column | PII tag |
|---|---|
| technician_name | **full_name** |
| technician_email | **email** |

### `customers.b2b_customers`
| Column | PII tag |
|---|---|
| primary_contact_name | **full_name** |
| primary_contact_email | **email** |
| primary_contact_phone | **phone** |
| billing_street | **address** |

### `customers.drivers`
| Column | PII tag |
|---|---|
| full_name | **full_name** |
| email | **email** |
| phone | **phone** |
| home_address | **address** |
| vehicle_vin | **vehicle_id** |
| license_plate | **vehicle_id** |
| payment_token | **payment** |
| card_last4 | **payment** |

### `operations.charging_sessions`
No direct PII (driver_id is a pseudonym to `drivers`).

### `operations.session_payments`
| Column | PII tag |
|---|---|
| payment_token | **payment** |
| card_last4 | **payment** |

### `operations.alarms`
acknowledged_by is an internal username — not customer PII, intentionally untagged.

### `billing.tariffs`
base_kwh_price, idle_fee_per_min, session_start_fee are commercially
sensitive → `data_classification=confidential`, but not PII.

### `billing.invoices`
| Column | PII tag |
|---|---|
| billing_contact_email | **email** |

## Governed tag schema

| Tag key | Values |
|---|---|
| `data_classification` | public, internal, confidential, restricted |
| `pii_type` | email, full_name, phone, address, vehicle_id, payment, geo_precise |
