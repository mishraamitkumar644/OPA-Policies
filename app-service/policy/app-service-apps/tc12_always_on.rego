# TC-12: Always On must be enabled (for production-tier plans)
package azure.appservice.apps.tc12_always_on

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not resource.values.site_config[_].always_on == true
  msg := sprintf("FAIL TC-12: App '%s' must have always_on = true.", [resource.address])
}
