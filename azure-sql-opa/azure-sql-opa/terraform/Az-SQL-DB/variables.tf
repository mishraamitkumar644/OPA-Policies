# ------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-sql-compliance"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "canadacentral"
}

variable "sql_server_name" {
  type        = string
  description = "Azure SQL Server name (must be globally unique)"
}

variable "sql_database_name" {
  type        = string
  description = "Azure SQL Database name"
  default     = "sqldb-compliance"
}

variable "admin_login" {
  type        = string
  description = "SQL Server admin login"
  default     = "sqladmin"
}

variable "admin_password" {
  type        = string
  description = "SQL Server admin password"
  sensitive   = true
}

variable "entra_admin_login" {
  type        = string
  description = "Microsoft Entra admin display name"
}

variable "entra_admin_object_id" {
  type        = string
  description = "Microsoft Entra admin object ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name for Customer Managed Key"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name for audit logs"
}

variable "auditing_retention_days" {
  type        = number
  description = "Audit log retention in days (must be > 90)"
  default     = 91

  validation {
    condition     = var.auditing_retention_days > 90
    error_message = "Auditing retention must be greater than 90 days."
  }
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.min_tls_version)
    error_message = "Minimum TLS version must be 1.2 or higher."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    environment = "compliance"
    managed_by  = "terraform"
  }
}
