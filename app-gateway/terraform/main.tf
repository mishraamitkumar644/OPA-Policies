##############################################################
# Application Gateway — main.tf
# Test Cases:
#   TC-01: SSL Min Protocol Version >= TLSv1_2
#   TC-02: HTTP2 Enabled
##############################################################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "agw_subnet" {
  name                 = "snet-agw-${var.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "agw_pip" {
  name                = "pip-agw-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # TC-02: HTTP2 must be enabled
  http2_enabled = var.enable_http2

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = azurerm_subnet.agw_subnet.id
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "feip-public"
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "feip-public"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "agw-ssl-cert"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  ssl_certificate {
    name     = "agw-ssl-cert"
    data     = var.ssl_certificate_data
    password = var.ssl_certificate_password
  }

  # TC-01: SSL Policy — minimum protocol version must be TLSv1_2 or higher
  ssl_policy {
    policy_type          = "Custom"
    min_protocol_version = var.ssl_min_protocol_version
    cipher_suites        = var.ssl_cipher_suites
  }
}
