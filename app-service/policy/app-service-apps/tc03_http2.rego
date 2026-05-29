# TC-03: HTTP/2 must be enabled
package azure.appservice.apps.tc03_http2

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not resource.values.site_config[_].http2_enabled == true
  msg := sprintf("FAIL TC-03: App '%s' must have http2_enabled = true.", [resource.address])
}
