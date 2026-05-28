##############################################################
# Virtual Machine — outputs.tf
##############################################################

output "vm_id" {
  description = "Resource ID of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_identity_principal_id" {
  description = "System-assigned Managed Identity principal ID (used for Entra ID access)"
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "installed_extensions" {
  description = "Names of all extensions installed on the VM"
  value       = [for ext in azurerm_virtual_machine_extension.extensions : ext.name]
}
