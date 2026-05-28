# ============================================================
# TC-02: Only MFA Enabled Identities Can Access Privileged VM
#
# This policy enforces two requirements together:
#
# 1. The VM must have a System-assigned Managed Identity
#    (identity block with type = "SystemAssigned").
#    This is required for AAD-based authentication.
#
# 2. The AADSSHLoginForLinux extension must be installed.
#    This extension integrates Entra ID (Azure AD) MFA
#    authentication for SSH access, replacing password/key
#    login with identity-based MFA-enforced login.
#
# Both conditions must be met. If either is missing, the VM
# allows access without MFA enforcement — which is a FAIL.
# ============================================================
package azure.vm.tc02_mfa_identity_access

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# ---- HELPER: Linux VMs ----
linux_vms[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_linux_virtual_machine"
}

# ---- HELPER: All VM extension resources ----
vm_extensions[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_virtual_machine_extension"
}

# ---- HELPER: Check if AADSSHLoginForLinux is present ----
aad_ssh_extension_present if {
  vm_extensions[ext]
  ext.change.after.type == "AADSSHLoginForLinux"
  ext.change.after.publisher == "Microsoft.Azure.ActiveDirectory"
}

# ---- HELPER: Check VM has SystemAssigned identity ----
has_system_identity(vm) if {
  identity := vm.change.after.identity[_]
  identity.type == "SystemAssigned"
}

# ---- DENY RULE 1: VM has no Managed Identity configured ----
deny contains msg if {
  linux_vms[vm]
  identities := vm.change.after.identity
  count(identities) == 0
  msg := sprintf(
    "TC-02 FAIL: VM '%v' — No Managed Identity configured. A SystemAssigned identity is required for Entra ID MFA-based access.",
    [vm.address]
  )
}

# ---- DENY RULE 2: Identity type is not SystemAssigned ----
deny contains msg if {
  linux_vms[vm]
  identity := vm.change.after.identity[_]
  identity.type != "SystemAssigned"
  msg := sprintf(
    "TC-02 FAIL: VM '%v' — Identity type is '%v'. Must be 'SystemAssigned' for Entra ID MFA enforcement.",
    [vm.address, identity.type]
  )
}

# ---- DENY RULE 3: AADSSHLoginForLinux extension is missing ----
deny contains msg if {
  linux_vms[vm]
  not aad_ssh_extension_present
  msg := sprintf(
    "TC-02 FAIL: VM '%v' — 'AADSSHLoginForLinux' extension (publisher: Microsoft.Azure.ActiveDirectory) is NOT installed. This extension is required to enforce MFA-only SSH access via Entra ID.",
    [vm.address]
  )
}
