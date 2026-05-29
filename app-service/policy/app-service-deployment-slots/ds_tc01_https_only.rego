# DS-TC-01: Deployment Slot must enforce HTTPS only
package azure.appservice.slots.ds_tc01_https_only

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  not resource.values.https_only == true
  msg := sprintf("FAIL DS-TC-01: Slot '%s' must have https_only = true.", [resource.address])
}
