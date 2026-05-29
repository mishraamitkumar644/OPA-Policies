# TC-11: FTPS state must be FtpsOnly or Disabled — plain FTP not allowed
package azure.appservice.apps.tc11_ftps_only

import future.keywords.if
import future.keywords.in

allowed_ftps_states := {"FtpsOnly", "Disabled"}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  state := resource.values.site_config[_].ftps_state
  not state in allowed_ftps_states
  msg := sprintf("FAIL TC-11: App '%s' ftps_state is '%s'. Must be 'FtpsOnly' or 'Disabled'.", [resource.address, state])
}
