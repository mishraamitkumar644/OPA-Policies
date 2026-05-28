# ============================================================
# TC-01: SSL Minimum Protocol Version >= TLSv1_2
#
# Azure Application Gateway ssl_policy must define a
# min_protocol_version of TLSv1_2 or TLSv1_3.
# TLSv1_0 and TLSv1_1 are NOT acceptable.
# ============================================================
package azure.appgateway.tc01_ssl_min_protocol

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# ---- HELPER ----
# Filter all Application Gateway resources from the plan
app_gateways[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_application_gateway"
}

# Allowed protocol versions
allowed_protocols := {"TLSv1_2", "TLSv1_3"}

# ---- DENY RULE 1: No ssl_policy block defined ----
deny contains msg if {
  app_gateways[resource]
  ssl_policies := resource.change.after.ssl_policy
  count(ssl_policies) == 0
  msg := sprintf(
    "TC-01 FAIL: Resource '%v' — No ssl_policy block defined. A Custom ssl_policy with min_protocol_version TLSv1_2 or higher is required.",
    [resource.address]
  )
}

# ---- DENY RULE 2: min_protocol_version missing ----
deny contains msg if {
  app_gateways[resource]
  ssl_policy := resource.change.after.ssl_policy[_]
  not ssl_policy.min_protocol_version
  msg := sprintf(
    "TC-01 FAIL: Resource '%v' — ssl_policy exists but min_protocol_version is not set.",
    [resource.address]
  )
}

# ---- DENY RULE 3: min_protocol_version is below TLSv1_2 ----
deny contains msg if {
  app_gateways[resource]
  ssl_policy := resource.change.after.ssl_policy[_]
  proto := ssl_policy.min_protocol_version
  not allowed_protocols[proto]
  msg := sprintf(
    "TC-01 FAIL: Resource '%v' — ssl_policy min_protocol_version is '%v'. Must be TLSv1_2 or TLSv1_3.",
    [resource.address, proto]
  )
}
