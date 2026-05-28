# ------------------------------------------------------------------
# TC-4: Microsoft Entra authentication must be configured for SQL Server
# ------------------------------------------------------------------

package azure.sql.tc04_entra_auth

import future.keywords.if
import future.keywords.contains

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  not resource.change.after.azuread_administrator
  msg := sprintf(
    "TC-04 FAIL: Resource '%v' — Microsoft Entra administrator is not configured.",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  admin := resource.change.after.azuread_administrator[_]
  not admin.object_id
  msg := sprintf(
    "TC-04 FAIL: Resource '%v' — Entra admin object_id is missing.",
    [resource.address]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  admin := resource.change.after.azuread_administrator[_]
  admin.object_id == ""
  msg := sprintf(
    "TC-04 FAIL: Resource '%v' — Entra admin object_id must not be empty.",
    [resource.address]
  )
}
