# --------------------------------------------------------------------------
# Tag policy strategy for this demo
# --------------------------------------------------------------------------
# In a customer's production metastore you would normally create your own
# governed tags via `databricks_tag_policy` (one for data_classification,
# one for pii_type, with a controlled allowed-value list). That code is left
# below, commented out, as a reference for the customer's prod rollout.
#
# In the shared E2-Demo-Field-Eng metastore the per-account 1000 tag-policy
# cap is already exhausted by built-in `class.*` system tags. We therefore
# REUSE those existing tag keys for the demo. The `class.*` keys are
# presence-only (no allowed values), which still lets ABAC's hasTag()
# condition route a column to the right masking function.
# --------------------------------------------------------------------------

# ─── PRODUCTION REFERENCE (commented for shared demo) ─────────────────────
# resource "databricks_tag_policy" "data_classification" {
#   tag_key     = "${var.tag_prefix}data_classification"
#   description = "Coarse sensitivity label on every column that holds business data."
#   values = [
#     { name = "public" },
#     { name = "internal" },
#     { name = "confidential" },
#     { name = "restricted" },
#   ]
# }
#
# resource "databricks_tag_policy" "pii_type" {
#   tag_key     = "${var.tag_prefix}pii_type"
#   description = "Specific PII category. ABAC policies route columns by this value."
#   values = [
#     { name = "email" }, { name = "full_name" }, { name = "phone" },
#     { name = "address" }, { name = "vehicle_id" }, { name = "payment" },
#   ]
# }
# ──────────────────────────────────────────────────────────────────────────
