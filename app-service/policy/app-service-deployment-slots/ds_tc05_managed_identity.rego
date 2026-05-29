# DS-TC-05: Managed identity must be enabled on slot
package azure.appservice.slots.ds_tc05_managed_identity

import future.keywords.if
import future.keywords.in

valid_types := {"SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  count(resource.values.identity) == 0
  msg := sprintf("FAIL DS-TC-05: Slot '%s' has no managed identity configured.", [resource.address])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  identity := resource.values.identity[_]
  not identity.type in valid_types
  msg := sprintf("FAIL DS-TC-05: Slot '%s' identity type '%s' is invalid.", [resource.address, identity.type])
}
