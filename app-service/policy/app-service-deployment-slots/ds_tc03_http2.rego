# DS-TC-03: HTTP/2 must be enabled on slot
package azure.appservice.slots.ds_tc03_http2

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  not resource.values.site_config[_].http2_enabled == true
  msg := sprintf("FAIL DS-TC-03: Slot '%s' must have http2_enabled = true.", [resource.address])
}
