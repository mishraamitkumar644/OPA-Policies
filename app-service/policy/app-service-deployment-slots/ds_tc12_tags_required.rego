# DS-TC-12: Required tags must be present on slot
package azure.appservice.slots.ds_tc12_tags_required

import future.keywords.if
import future.keywords.in

required_tags := {"Environment", "Owner", "CostCenter"}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  tag := required_tags[_]
  not resource.values.tags[tag]
  msg := sprintf("FAIL DS-TC-12: Slot '%s' is missing required tag '%s'.", [resource.address, tag])
}
