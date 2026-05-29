# DS-TC-04: Remote debugging must be disabled on slot
package azure.appservice.slots.ds_tc04_remote_debug_off

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  resource.values.site_config[_].remote_debugging_enabled == true
  msg := sprintf("FAIL DS-TC-04: Slot '%s' has remote debugging enabled. Must be false.", [resource.address])
}
