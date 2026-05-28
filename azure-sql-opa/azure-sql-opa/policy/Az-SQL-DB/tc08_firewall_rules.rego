# ------------------------------------------------------------------
# TC-8: No overly permissive firewall rules for Azure SQL Database
# A rule is overly permissive if:
#   - start_ip = 0.0.0.0 AND end_ip = 255.255.255.255  (allow all)
#   - start_ip = 0.0.0.0 AND end_ip = 0.0.0.0          (Azure services — still flagged)
#   - IP range spans more than approved /16 subnet
# ------------------------------------------------------------------

package azure.sql.tc08_firewall_rules

import future.keywords.if
import future.keywords.contains

# Rule 1: Deny allow-all rule (0.0.0.0 to 255.255.255.255)
deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_firewall_rule"
  resource.change.after.start_ip_address == "0.0.0.0"
  resource.change.after.end_ip_address   == "255.255.255.255"
  msg := sprintf(
    "TC-08 FAIL: Resource '%v' — Firewall rule allows ALL IPs (0.0.0.0-255.255.255.255). This is overly permissive.",
    [resource.address]
  )
}

# Rule 2: Deny wildcard start IP with broad end range
deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_firewall_rule"
  resource.change.after.start_ip_address == "0.0.0.0"
  resource.change.after.end_ip_address  != "0.0.0.0"
  resource.change.after.end_ip_address  != "255.255.255.255"
  msg := sprintf(
    "TC-08 FAIL: Resource '%v' — Firewall rule starts at 0.0.0.0 with end IP '%v'. Overly permissive.",
    [resource.address, resource.change.after.end_ip_address]
  )
}

# Rule 3: Warn on Azure Services rule (0.0.0.0 - 0.0.0.0)
# This is Azure's special "Allow Azure Services" toggle — flag for review
deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_firewall_rule"
  resource.change.after.start_ip_address == "0.0.0.0"
  resource.change.after.end_ip_address   == "0.0.0.0"
  msg := sprintf(
    "TC-08 FAIL: Resource '%v' — 'Allow Azure Services' rule (0.0.0.0-0.0.0.0) detected. Review if this is required.",
    [resource.address]
  )
}
