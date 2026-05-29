# DS-TC-07: Application Insights must be connected on slot
package azure.appservice.slots.ds_tc07_app_insights

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  settings := resource.values.app_settings
  not settings.APPLICATIONINSIGHTS_CONNECTION_STRING
  not settings.APPINSIGHTS_INSTRUMENTATIONKEY
  msg := sprintf("FAIL DS-TC-07: Slot '%s' has no Application Insights connection.", [resource.address])
}
