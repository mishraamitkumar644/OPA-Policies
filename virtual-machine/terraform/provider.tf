##############################################################
# Virtual Machine — provider.tf
##############################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
