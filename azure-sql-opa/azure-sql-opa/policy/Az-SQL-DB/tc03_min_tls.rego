# ------------------------------------------------------------------
# TC-3: Minimum TLS version must be 1.2 or higher
# ------------------------------------------------------------------

package azure.sql.tc03_min_tls

import future.keywords.if
import future.keywords.contains

allowed_tls_versions := {"1.2", "1.3"}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  tls := resource.change.after.minimum_tls_version
  not allowed_tls_versions[tls]
  msg := sprintf(
    "TC-03 FAIL: Resource '%v' — minimum_tls_version is '%v'. Must be 1.2 or higher.",
    [resource.address, tls]
  )
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  not resource.change.after.minimum_tls_version
  msg := sprintf(
    "TC-03 FAIL: Resource '%v' — minimum_tls_version is not set. Must be 1.2 or higher.",
    [resource.address]
  )
}
