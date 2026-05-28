##############################################################
# Application Gateway — variables.tf
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
  default     = "rg-agw-opa-test"
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "eastus"
}

variable "prefix" {
  type        = string
  description = "Prefix for all resource names"
  default     = "opa-test"
}

# TC-02: HTTP2
variable "enable_http2" {
  type        = bool
  description = "TC-02: HTTP2 must be enabled on Application Gateway"
  default     = true
}

# TC-01: SSL Policy
variable "ssl_min_protocol_version" {
  type        = string
  description = "TC-01: Minimum SSL/TLS protocol version. Must be TLSv1_2 or TLSv1_3"
  default     = "TLSv1_2"

  validation {
    condition     = contains(["TLSv1_2", "TLSv1_3"], var.ssl_min_protocol_version)
    error_message = "SSL minimum protocol version must be TLSv1_2 or TLSv1_3."
  }
}

variable "ssl_cipher_suites" {
  type        = list(string)
  description = "List of allowed TLS cipher suites"
  default = [
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  ]
}

variable "ssl_certificate_data" {
  type        = string
  description = "Base64-encoded PFX certificate data"
  sensitive   = true
  default     = ""
}

variable "ssl_certificate_password" {
  type        = string
  description = "Password for the PFX certificate"
  sensitive   = true
  default     = ""
}
