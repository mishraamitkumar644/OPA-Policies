# TC-06: Client certificate must be required
package azure.appservice.apps.tc06_client_cert

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not resource.values.client_certificate_enabled == true
  msg := sprintf("FAIL TC-06: App '%s' must have client_certificate_enabled = true.", [resource.address])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  resource.values.client_certificate_enabled == true
  mode := resource.values.client_certificate_mode
  not mode == "Required"
  msg := sprintf("FAIL TC-06: App '%s' client_certificate_mode is '%s'. Must be 'Required'.", [resource.address, mode])
}
