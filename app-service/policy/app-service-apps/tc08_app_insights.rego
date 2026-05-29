# TC-08: Application Insights must be connected
package azure.appservice.apps.tc08_app_insights

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  settings := resource.values.app_settings
  not settings.APPLICATIONINSIGHTS_CONNECTION_STRING
  not settings.APPINSIGHTS_INSTRUMENTATIONKEY
  msg := sprintf("FAIL TC-08: App '%s' has no Application Insights connection configured.", [resource.address])
}
