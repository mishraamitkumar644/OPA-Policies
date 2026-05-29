# DS-TC-06: Authentication must be enabled on slot
package azure.appservice.slots.ds_tc06_auth_enabled

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  count(resource.values.auth_settings) == 0
  msg := sprintf("FAIL DS-TC-06: Slot '%s' has no auth_settings configured.", [resource.address])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  auth := resource.values.auth_settings[_]
  not auth.enabled == true
  msg := sprintf("FAIL DS-TC-06: Slot '%s' auth_settings.enabled is false.", [resource.address])
}
