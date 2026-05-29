# TC-04: Remote debugging must be disabled
package azure.appservice.apps.tc04_remote_debug_off

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  resource.values.site_config[_].remote_debugging_enabled == true
  msg := sprintf("FAIL TC-04: App '%s' has remote debugging enabled. Must be false.", [resource.address])
}
