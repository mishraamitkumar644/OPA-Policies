# TC-05: Managed identity must be enabled
package azure.appservice.apps.tc05_managed_identity

import future.keywords.if
import future.keywords.in

valid_identity_types := {"SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  identities := resource.values.identity
  count(identities) == 0
  msg := sprintf("FAIL TC-05: App '%s' has no managed identity configured.", [resource.address])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  identity := resource.values.identity[_]
  not identity.type in valid_identity_types
  msg := sprintf("FAIL TC-05: App '%s' identity type '%s' is not valid.", [resource.address, identity.type])
}
