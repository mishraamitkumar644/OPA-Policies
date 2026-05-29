# TC-16: At least one IP restriction rule must be defined (deny-all or allow-list)
package azure.appservice.apps.tc16_ip_restrictions

import future.keywords.if

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  restrictions := resource.values.site_config[_].ip_restriction
  count(restrictions) == 0
  msg := sprintf("FAIL TC-16: App '%s' has no IP restrictions configured.", [resource.address])
}
