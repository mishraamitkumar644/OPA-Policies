# DS-TC-10: Diagnostic settings must be configured for the slot
package azure.appservice.slots.ds_tc10_diagnostic_settings

import future.keywords.if

diag_target_ids[id] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_monitor_diagnostic_setting"
  id := resource.values.target_resource_id
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  not diag_target_ids[resource.values.id]
  msg := sprintf("FAIL DS-TC-10: Slot '%s' has no azurerm_monitor_diagnostic_setting configured.", [resource.address])
}
