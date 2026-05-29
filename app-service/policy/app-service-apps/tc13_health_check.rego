# TC-13: Health check path must be configured
package azure.appservice.apps.tc13_health_check

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  path := resource.values.site_config[_].health_check_path
  not path
  msg := sprintf("FAIL TC-13: App '%s' has no health_check_path configured.", [resource.address])
}
