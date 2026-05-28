# ------------------------------------------------------------------
# TC-2: Data encryption must be set to 'On' for Azure SQL Database
# ------------------------------------------------------------------

package azure.sql.tc02_data_encryption

import future.keywords.if
import future.keywords.contains

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_database"
  not resource.change.after.transparent_data_encryption_enabled
  msg := sprintf(
    "TC-02 FAIL: Resource '%v' — transparent_data_encryption_enabled must be true.",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_database"
  resource.change.after.transparent_data_encryption_enabled == false
  msg := sprintf(
    "TC-02 FAIL: Resource '%v' — Data encryption is set to Off. Must be On.",
    [resource.address]
  )
}
