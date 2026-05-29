# TC-07: Authentication (EasyAuth) must be enabled
package azure.appservice.apps.tc07_auth_enabled

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  auth := resource.values.auth_settings
  count(auth) == 0
  msg := sprintf("FAIL TC-07: App '%s' has no auth_settings configured.", [resource.address])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  auth := resource.values.auth_settings[_]
  not auth.enabled == true
  msg := sprintf("FAIL TC-07: App '%s' auth_settings.enabled is false.", [resource.address])
}
