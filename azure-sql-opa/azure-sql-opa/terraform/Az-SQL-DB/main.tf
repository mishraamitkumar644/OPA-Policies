# ------------------------------------------------------------------
# Provider
# ------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

# ------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------

data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------
# Storage Account (for audit logs)
# ------------------------------------------------------------------

resource "azurerm_storage_account" "audit" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

# ------------------------------------------------------------------
# Key Vault (for Customer Managed Key / TDE)
# ------------------------------------------------------------------

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  tags                        = var.tags
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create", "Get", "List", "Delete", "Purge",
    "GetRotationPolicy", "WrapKey", "UnwrapKey"
  ]
}

resource "azurerm_key_vault_key" "tde_key" {
  name         = "tde-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# ------------------------------------------------------------------
# SQL Server
# TC-3: min_tls_version = 1.2
# TC-4: Microsoft Entra admin configured
# TC-7: public_network_access_enabled = false
# ------------------------------------------------------------------

resource "azurerm_mssql_server" "sql" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = var.admin_login
  administrator_login_password  = var.admin_password
  minimum_tls_version           = var.min_tls_version        # TC-3
  public_network_access_enabled = false                      # TC-7
  tags                          = var.tags

  # TC-4: Microsoft Entra authentication
  azuread_administrator {
    login_username = var.entra_admin_login
    object_id      = var.entra_admin_object_id
    tenant_id      = var.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }
}

# Key Vault access for SQL Server managed identity (needed for TDE CMK)
resource "azurerm_key_vault_access_policy" "sql" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_mssql_server.sql.identity[0].principal_id

  key_permissions = ["Get", "WrapKey", "UnwrapKey"]
}

# ------------------------------------------------------------------
# SQL Database
# TC-2: transparent_data_encryption_enabled = true
# ------------------------------------------------------------------

resource "azurerm_mssql_database" "db" {
  name         = var.sql_database_name
  server_id    = azurerm_mssql_server.sql.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  sku_name     = "S0"
  tags         = var.tags

  # TC-2: Data encryption ON
  transparent_data_encryption_enabled = true
}

# ------------------------------------------------------------------
# TC-1: TDE with Customer Managed Key
# ------------------------------------------------------------------

resource "azurerm_mssql_server_transparent_data_encryption" "tde" {
  server_id        = azurerm_mssql_server.sql.id
  key_vault_key_id = azurerm_key_vault_key.tde_key.id

  depends_on = [azurerm_key_vault_access_policy.sql]
}

# ------------------------------------------------------------------
# TC-5 & TC-6: Auditing ON + Retention > 90 days
# ------------------------------------------------------------------

resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  server_id                               = azurerm_mssql_server.sql.id
  storage_endpoint                        = azurerm_storage_account.audit.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.audit.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.auditing_retention_days  # TC-6: > 90
  enabled                                 = true                         # TC-5
}

# ------------------------------------------------------------------
# TC-8: Firewall rules — NO overly permissive rules
# Only specific IPs allowed (no 0.0.0.0 - 255.255.255.255)
# ------------------------------------------------------------------

# Example: Allow only specific IP (replace with your IP)
# resource "azurerm_mssql_firewall_rule" "allow_specific" {
#   name             = "allow-office-ip"
#   server_id        = azurerm_mssql_server.sql.id
#   start_ip_address = "203.0.113.10"
#   end_ip_address   = "203.0.113.10"
# }

# NOTE: Do NOT add rules with start=0.0.0.0 end=255.255.255.255
# OPA policy will catch and deny overly permissive rules
