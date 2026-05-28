# ------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------

output "sql_server_name" {
  value = azurerm_mssql_server.sql.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.db.name
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "tde_key_id" {
  value = azurerm_key_vault_key.tde_key.id
}
