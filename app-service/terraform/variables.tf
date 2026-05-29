variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "opa-appservice"
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "rg-opa-appservice"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "aad_client_id" {
  description = "Azure AD App Registration client ID for EasyAuth"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Environment = "test"
    Owner       = "platform-team"
    CostCenter  = "12345"
  }
}
