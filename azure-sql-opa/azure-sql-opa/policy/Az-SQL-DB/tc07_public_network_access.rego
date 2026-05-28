# ------------------------------------------------------------------
# TC-7: Public Network Access must be set to 'Disable'
# ------------------------------------------------------------------

package azure.sql.tc07_public_network_access

import future.keywords.if
import future.keywords.contains

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  resource.change.after.public_network_access_enabled == true
  msg := sprintf(
    "TC-07 FAIL: Resource '%v' — public_network_access_enabled is true. Must be false (Disabled).",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  not resource.change.after.public_network_access_enabled == false
  resource.change.after.public_network_access_enabled == null
  msg := sprintf(
    "TC-07 FAIL: Resource '%v' — public_network_access_enabled is not explicitly set to false.",
    [resource.address]
  )
}
