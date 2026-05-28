# ============================================================
# TC-01: Only Approved Extensions Are Installed on the VM
#
# Every azurerm_virtual_machine_extension resource in the plan
# must have its 'type' field present in the approved allowlist.
# Any extension not in the list will trigger a DENY.
# ============================================================
package azure.vm.tc01_approved_extensions

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# ---- APPROVED EXTENSION ALLOWLIST ----
# Modify this set to match your organisation's policy
approved_extension_types := {
  "AADSSHLoginForLinux",
  "AzureMonitorLinuxAgent",
  "MicrosoftMonitoringAgent",
  "DependencyAgentLinux",
  "AzurePolicyLinux",
  "LinuxDiagnostic",
  "OmsAgentForLinux",
  "CustomScript"
}

# ---- HELPER ----
# Filter all VM extension resources from the plan
vm_extensions[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_virtual_machine_extension"
}

# ---- DENY RULE 1: Extension type not in approved list ----
deny contains msg if {
  vm_extensions[resource]
  ext_type := resource.change.after.type
  not approved_extension_types[ext_type]
  msg := sprintf(
    "TC-01 FAIL: Extension '%v' (type: '%v') is NOT in the approved extensions list. Remove it or add it to the allowlist.",
    [resource.address, ext_type]
  )
}

# ---- DENY RULE 2: Extension type field is missing ----
deny contains msg if {
  vm_extensions[resource]
  not resource.change.after.type
  msg := sprintf(
    "TC-01 FAIL: Extension '%v' — 'type' attribute is missing. Cannot validate against approved list.",
    [resource.address]
  )
}
