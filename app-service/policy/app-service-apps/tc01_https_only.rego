# TC-01: App Service must enforce HTTPS only
package azure.appservice.apps.tc01_https_only

import future.keywords.if
import future.keywords.in

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not resource.values.https_only == true
  msg := sprintf("FAIL TC-01: App '%s' must have https_only = true.", [resource.address])
}
