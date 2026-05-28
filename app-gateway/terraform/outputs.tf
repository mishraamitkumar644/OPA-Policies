##############################################################
# Application Gateway — outputs.tf
##############################################################

output "application_gateway_id" {
  description = "Resource ID of the Application Gateway"
  value       = azurerm_application_gateway.agw.id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.agw.name
}

output "ssl_min_protocol_version" {
  description = "Configured minimum SSL protocol version"
  value       = var.ssl_min_protocol_version
}

output "http2_enabled" {
  description = "HTTP2 enabled status"
  value       = var.enable_http2
}
