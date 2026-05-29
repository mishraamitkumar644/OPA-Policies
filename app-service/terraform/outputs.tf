output "compliant_app_url" {
  value = "https://${azurerm_linux_web_app.compliant.default_hostname}"
}

output "non_compliant_app_url" {
  value = "https://${azurerm_linux_web_app.non_compliant.default_hostname}"
}

output "staging_slot_url" {
  value = "https://${azurerm_linux_web_app_slot.slot_compliant.default_hostname}"
}
