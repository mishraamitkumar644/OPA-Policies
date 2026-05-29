# TC-02: Minimum TLS version must be 1.2
package azure.appservice.apps.tc02_min_tls

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  tls := resource.values.site_config[_].minimum_tls_version
  not tls == "1.2"
  msg := sprintf("FAIL TC-02: App '%s' TLS version is '%s'. Must be 1.2.", [resource.address, tls])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not resource.values.site_config[_].minimum_tls_version
  msg := sprintf("FAIL TC-02: App '%s' has no minimum_tls_version set.", [resource.address])
}
