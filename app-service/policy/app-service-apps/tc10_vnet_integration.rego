# TC-10: VNet integration must be configured
package azure.appservice.apps.tc10_vnet_integration

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not resource.values.virtual_network_subnet_id
  msg := sprintf("FAIL TC-10: App '%s' has no VNet integration (virtual_network_subnet_id missing).", [resource.address])
}
