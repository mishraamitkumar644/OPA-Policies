###############################################################
# App Service Apps + Deployment Slots — Terraform (main.tf)
###############################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

# ── Resource Group ────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ── App Service Plan ──────────────────────────────────────────
resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v3"
}

# ── Log Analytics Workspace ───────────────────────────────────
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── App Insights ──────────────────────────────────────────────
resource "azurerm_application_insights" "ai" {
  name                = "${var.prefix}-ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

# ── Storage Account (for diagnostics) ────────────────────────
resource "azurerm_storage_account" "sa" {
  name                     = lower(replace("${var.prefix}sa", "-", ""))
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  https_traffic_only_enabled       = true
}

# ── Key Vault ─────────────────────────────────────────────────
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete"]
  }
}

# ── Virtual Network + Subnet ──────────────────────────────────
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

###############################################################
# App Service — COMPLIANT (all policy rules satisfied)
###############################################################
resource "azurerm_linux_web_app" "compliant" {
  name                = "${var.prefix}-app-compliant"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  # TC-01: HTTPS only
  https_only = true

  # TC-02: Minimum TLS 1.2
  # TC-03: Latest HTTP/2
  # TC-04: Remote debugging OFF
  # TC-05: Managed identity enabled
  # TC-11: FTPS only (no plain FTP)
  site_config {
    minimum_tls_version  = "1.2"
    http2_enabled        = true
    remote_debugging_enabled = false
    ftps_state           = "FtpsOnly"

    # TC-06: Client cert mode
    # (set at resource level below)

    application_stack {
      python_version = "3.11"
    }

    # TC-16: Health check path
    health_check_path = "/health"
  }

  # TC-05: System-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # TC-07: Auth enabled (EasyAuth)
  auth_settings {
    enabled = true
    default_provider = "AzureActiveDirectory"
    active_directory {
      client_id = var.aad_client_id
    }
  }

  # TC-08: App Insights connection
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.ai.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.ai.connection_string
    # TC-09: No plain-text secrets — using Key Vault references
    "DB_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.kv.vault_uri}secrets/db-password/)"
  }

  # TC-10: Client cert required
  client_certificate_enabled = true
  client_certificate_mode    = "Required"

  # TC-12: VNet integration
  virtual_network_subnet_id = azurerm_subnet.subnet.id

  # TC-13: Always On
  # (set inside site_config — handled via always_on default true on P-tier)

  # TC-14: Diagnostic settings (via separate resource below)

  # TC-15: Tags
  tags = var.tags

  logs {
    http_logs {
      retention_in_days = 30
    }
    application_logs {
      file_system_level = "Warning"
    }
    detailed_error_messages = true
    failed_request_tracing  = true
  }
}

# TC-14: Diagnostic settings for compliant app
resource "azurerm_monitor_diagnostic_setting" "app_diag" {
  name                       = "${var.prefix}-app-diag"
  target_resource_id         = azurerm_linux_web_app.compliant.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  storage_account_id         = azurerm_storage_account.sa.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# TC-17: Private endpoint
resource "azurerm_private_endpoint" "app_pe" {
  name                = "${var.prefix}-app-pe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${var.prefix}-app-psc"
    private_connection_resource_id = azurerm_linux_web_app.compliant.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

# TC-18: IP restrictions (access restrictions)
resource "azurerm_linux_web_app" "restricted" {
  name                = "${var.prefix}-app-restricted"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version      = "1.2"
    http2_enabled            = true
    remote_debugging_enabled = false
    ftps_state               = "FtpsOnly"

    ip_restriction {
      ip_address = "10.0.0.0/8"
      action     = "Allow"
      priority   = 100
      name       = "allow-internal"
    }

    ip_restriction {
      ip_address = "0.0.0.0/0"
      action     = "Deny"
      priority   = 2147483647
      name       = "deny-all"
    }
  }

  tags = var.tags
}

###############################################################
# App Service — NON-COMPLIANT (intentional violations for TC)
###############################################################
resource "azurerm_linux_web_app" "non_compliant" {
  name                = "${var.prefix}-app-noncompliant"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  # TC-01 FAIL: https_only = false
  https_only = false

  site_config {
    # TC-02 FAIL: TLS 1.0
    minimum_tls_version      = "1.0"
    # TC-03 FAIL: HTTP/2 disabled
    http2_enabled            = false
    # TC-04 FAIL: Remote debug ON
    remote_debugging_enabled = true
    # TC-11 FAIL: FTP allowed
    ftps_state               = "AllAllowed"
  }

  # TC-05 FAIL: No identity block
  # TC-07 FAIL: No auth_settings
  # TC-10 FAIL: No client cert

  app_settings = {
    # TC-09 FAIL: Plain-text secret
    "DB_PASSWORD" = "SuperSecret123!"
  }

  tags = {}  # TC-15 FAIL: No tags
}

###############################################################
# Deployment Slots — COMPLIANT
###############################################################
resource "azurerm_linux_web_app_slot" "slot_compliant" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.compliant.id

  # DS-TC-01: HTTPS only
  https_only = true

  # DS-TC-02 / 03 / 04
  site_config {
    minimum_tls_version      = "1.2"
    http2_enabled            = true
    remote_debugging_enabled = false
    ftps_state               = "FtpsOnly"
    health_check_path        = "/health"
  }

  # DS-TC-05: Managed identity
  identity {
    type = "SystemAssigned"
  }

  # DS-TC-06: Auth
  auth_settings {
    enabled          = true
    default_provider = "AzureActiveDirectory"
    active_directory {
      client_id = var.aad_client_id
    }
  }

  # DS-TC-07: App Insights
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.ai.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.ai.connection_string
  }

  # DS-TC-08: Client cert
  client_certificate_enabled = true
  client_certificate_mode    = "Required"

  # DS-TC-09: VNet
  virtual_network_subnet_id = azurerm_subnet.subnet.id

  tags = var.tags
}

# DS-TC-10: Diagnostic settings for slot
resource "azurerm_monitor_diagnostic_setting" "slot_diag" {
  name                       = "${var.prefix}-slot-diag"
  target_resource_id         = azurerm_linux_web_app_slot.slot_compliant.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  storage_account_id         = azurerm_storage_account.sa.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

###############################################################
# Deployment Slots — NON-COMPLIANT
###############################################################
resource "azurerm_linux_web_app_slot" "slot_non_compliant" {
  name           = "dev"
  app_service_id = azurerm_linux_web_app.compliant.id

  # DS-TC-01 FAIL
  https_only = false

  site_config {
    minimum_tls_version      = "1.0"
    http2_enabled            = false
    remote_debugging_enabled = true
    ftps_state               = "AllAllowed"
  }

  app_settings = {
    "DB_PASSWORD" = "PlainTextPassword!"
  }

  tags = {}
}
