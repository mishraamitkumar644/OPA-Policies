# TC-18: Public network access should be restricted via IP allowlist or private endpoint
package azure.appservice.apps.tc18_no_public_access

import future.keywords.if
import future.keywords.in

has_deny_all_rule(resource) if {
  rule := resource.values.site_config[_].ip_restriction[_]
  rule.action == "Deny"
  rule.ip_address == "0.0.0.0/0"
}

has_private_endpoint(resource) if {
  pe := input.planned_values.root_module.resources[_]
  pe.type == "azurerm_private_endpoint"
  psc := pe.values.private_service_connection[_]
  psc.private_connection_resource_id == resource.values.id
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  not has_deny_all_rule(resource)
  not has_private_endpoint(resource)
  msg := sprintf("FAIL TC-18: App '%s' has unrestricted public access. Add deny-all IP rule or private endpoint.", [resource.address])
}
