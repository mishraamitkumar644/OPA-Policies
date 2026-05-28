# ------------------------------------------------------------------
# TC-5: Auditing must be set to 'On' for Azure SQL Database
# ------------------------------------------------------------------

package azure.sql.tc05_auditing_enabled

import future.keywords.if
import future.keywords.contains

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_extended_auditing_policy"
  not resource.change.after.enabled
  msg := sprintf(
    "TC-05 FAIL: Resource '%v' — Auditing is not enabled. Must be set to On.",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_extended_auditing_policy"
  resource.change.after.enabled == false
  msg := sprintf(
    "TC-05 FAIL: Resource '%v' — Auditing is explicitly set to Off. Must be On.",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_extended_auditing_policy"
  not resource.change.after.storage_endpoint
  msg := sprintf(
    "TC-05 FAIL: Resource '%v' — Auditing storage_endpoint is not configured.",
    [resource.address]
  )
}
