# TC-15: Required tags must be present
package azure.appservice.apps.tc15_tags_required

import future.keywords.if
import future.keywords.in

required_tags := {"Environment", "Owner", "CostCenter"}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  tag := required_tags[_]
  not resource.values.tags[tag]
  msg := sprintf("FAIL TC-15: App '%s' is missing required tag '%s'.", [resource.address, tag])
}
