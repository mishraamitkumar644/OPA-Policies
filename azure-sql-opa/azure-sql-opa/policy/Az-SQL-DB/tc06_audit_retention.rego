# ------------------------------------------------------------------
# TC-6: Auditing retention must be greater than 90 days
# ------------------------------------------------------------------

package azure.sql.tc06_audit_retention

import future.keywords.if
import future.keywords.contains

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_extended_auditing_policy"
  retention := resource.change.after.retention_in_days
  retention <= 90
  msg := sprintf(
    "TC-06 FAIL: Resource '%v' — Auditing retention is %v days. Must be greater than 90 days.",
    [resource.address, retention]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server_extended_auditing_policy"
  not resource.change.after.retention_in_days
  msg := sprintf(
    "TC-06 FAIL: Resource '%v' — retention_in_days is not set. Must be greater than 90.",
    [resource.address]
  )
}
