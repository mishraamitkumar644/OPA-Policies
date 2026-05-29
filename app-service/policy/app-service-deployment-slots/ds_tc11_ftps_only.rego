# DS-TC-11: FTPS state on slot must be FtpsOnly or Disabled
package azure.appservice.slots.ds_tc11_ftps_only

import future.keywords.if
import future.keywords.in

allowed_states := {"FtpsOnly", "Disabled"}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app_slot"
  state := resource.values.site_config[_].ftps_state
  not state in allowed_states
  msg := sprintf("FAIL DS-TC-11: Slot '%s' ftps_state is '%s'. Must be 'FtpsOnly' or 'Disabled'.", [resource.address, state])
}
