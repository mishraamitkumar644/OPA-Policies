# ============================================================
# TC-02: HTTP2 Must Be Enabled on Application Gateway
#
# The enable_http2 attribute on azurerm_application_gateway
# must be set to true.
# ============================================================
package azure.appgateway.tc02_http2_enabled

import future.keywords.contains
import future.keywords.if

# ---- HELPER ----
app_gateways[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_application_gateway"
}

# ---- DENY RULE 1: enable_http2 attribute missing entirely ----
deny contains msg if {
  app_gateways[resource]
  not resource.change.after.enable_http2
  msg := sprintf(
    "TC-02 FAIL: Resource '%v' — enable_http2 is not set or is false. HTTP2 must be enabled on Application Gateway.",
    [resource.address]
  )
}

# ---- DENY RULE 2: enable_http2 explicitly set to false ----
deny contains msg if {
  app_gateways[resource]
  resource.change.after.enable_http2 == false
  msg := sprintf(
    "TC-02 FAIL: Resource '%v' — enable_http2 is explicitly set to false. HTTP2 must be enabled.",
    [resource.address]
  )
}
