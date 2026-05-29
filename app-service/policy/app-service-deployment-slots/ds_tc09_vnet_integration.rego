# DS-TC-09: VNet integration must be configured on slot
package azure.appservice.slots.ds_tc09_vnet_integration

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  not resource.values.virtual_network_subnet_id
  msg := sprintf("FAIL DS-TC-09: Slot '%s' has no VNet integration (virtual_network_subnet_id missing).", [resource.address])
}
