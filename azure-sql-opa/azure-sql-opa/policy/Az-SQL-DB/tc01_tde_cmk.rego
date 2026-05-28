# ------------------------------------------------------------------
# TC-1: SQL server TDE protector must use Customer Managed Key
# ------------------------------------------------------------------

package azure.sql.tc01_tde_cmk

import future.keywords.if
import future.keywords.contains

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_transparent_data_encryption"
  not resource.change.after.key_vault_key_id
  msg := sprintf(
    "TC-01 FAIL: Resource '%v' — TDE must use a Customer Managed Key (key_vault_key_id is missing).",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_transparent_data_encryption"
  resource.change.after.key_vault_key_id == ""
  msg := sprintf(
    "TC-01 FAIL: Resource '%v' — TDE key_vault_key_id must not be empty.",
    [resource.address]
  )
}
