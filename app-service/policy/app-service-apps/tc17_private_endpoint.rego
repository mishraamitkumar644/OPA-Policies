# TC-17: Private endpoint must be configured for the App Service
package azure.appservice.apps.tc17_private_endpoint

import future.keywords.if

app_with_private_endpoint[addr] if {
  pe := input.planned_values.root_module.resources[_]
  pe.type == "azurerm_private_endpoint"
  psc := pe.values.private_service_connection[_]
  app := input.planned_values.root_module.resources[_]
  app.type == "azurerm_linux_web_app"
  psc.private_connection_resource_id == app.values.id
  addr := app.address
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not app_with_private_endpoint[resource.address]
  msg := sprintf("FAIL TC-17: App '%s' has no private endpoint configured.", [resource.address])
}
