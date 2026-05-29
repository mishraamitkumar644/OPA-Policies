# TC-14: Diagnostic settings must be configured for the App Service
package azure.appservice.apps.tc14_diagnostic_settings

import future.keywords.if

# Collect all app service resource IDs
app_service_ids[id] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  id := resource.values.id
}

# Collect all diagnostic setting target IDs
diag_target_ids[id] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_monitor_diagnostic_setting"
  id := resource.values.target_resource_id
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not diag_target_ids[resource.values.id]
  msg := sprintf("FAIL TC-14: App '%s' has no azurerm_monitor_diagnostic_setting configured.", [resource.address])
}
