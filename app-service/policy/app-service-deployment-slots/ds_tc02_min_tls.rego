# DS-TC-02: Slot minimum TLS version must be 1.2
package azure.appservice.slots.ds_tc02_min_tls

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  tls := resource.values.site_config[_].minimum_tls_version
  not tls == "1.2"
  msg := sprintf("FAIL DS-TC-02: Slot '%s' TLS version is '%s'. Must be 1.2.", [resource.address, tls])
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  not resource.values.site_config[_].minimum_tls_version
  msg := sprintf("FAIL DS-TC-02: Slot '%s' has no minimum_tls_version set.", [resource.address])
}
