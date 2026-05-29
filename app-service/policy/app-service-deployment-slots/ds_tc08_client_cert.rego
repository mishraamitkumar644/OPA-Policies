# DS-TC-08: Client certificate must be required on slot
package azure.appservice.slots.ds_tc08_client_cert

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  not resource.values.client_certificate_enabled == true
  msg := sprintf("FAIL DS-TC-08: Slot '%s' must have client_certificate_enabled = true.", [resource.address])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  resource.values.client_certificate_enabled == true
  mode := resource.values.client_certificate_mode
  not mode == "Required"
  msg := sprintf("FAIL DS-TC-08: Slot '%s' client_certificate_mode is '%s'. Must be 'Required'.", [resource.address, mode])
}
