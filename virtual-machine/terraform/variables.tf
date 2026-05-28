##############################################################
# Virtual Machine — variables.tf
##############################################################

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
  default     = "rg-vm-opa-test"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "opa-vm"
}

variable "vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for admin login"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    environment = "opa-test"
    managed_by  = "terraform"
  }
}

##############################################################
# TC-01: Approved Extensions Allowlist
# OPA policy checks that every installed extension
# belongs to this list
##############################################################

variable "approved_extension_types" {
  type        = list(string)
  description = "TC-01: Allowlist of approved VM extension types"
  default = [
    "AADSSHLoginForLinux",          # Entra ID SSH login (MFA)
    "AzureMonitorLinuxAgent",       # Azure Monitor
    "MicrosoftMonitoringAgent",     # Log Analytics (legacy)
    "DependencyAgentLinux",         # VM Insights dependency
    "AzurePolicyLinux",             # Azure Policy guest config
    "LinuxDiagnostic",              # Diagnostics
    "OmsAgentForLinux",             # OMS agent
    "CustomScript"                  # Custom scripts (controlled)
  ]
}

##############################################################
# TC-01: Extensions to install on the VM
# Every entry here must also appear in approved_extension_types
##############################################################

variable "vm_extensions" {
  type = list(object({
    name                 = string
    publisher            = string
    type                 = string
    type_handler_version = string
  }))
  description = "TC-01: List of extensions to install. All must be in the approved list."
  default = [
    {
      name                 = "AzureMonitorLinuxAgent"
      publisher            = "Microsoft.Azure.Monitor"
      type                 = "AzureMonitorLinuxAgent"
      type_handler_version = "1.0"
    }
  ]
}
