##############################################################
# Virtual Machine — main.tf
# Test Cases:
#   TC-01: Only Approved Extensions Are Installed
#   TC-02: Only MFA Enabled Identities Can Access Privileged VM
##############################################################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "snet-vm-${var.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-${var.prefix}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # TC-02: System-assigned Managed Identity — required for
  # Entra ID / MFA-based access via AADSSHLoginForLinux extension
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

##############################################################
# TC-01: Only approved VM extensions
# Each extension in var.vm_extensions must be in the
# approved list defined in variables.tf
##############################################################

resource "azurerm_virtual_machine_extension" "extensions" {
  for_each = { for ext in var.vm_extensions : ext.name => ext }

  name                       = each.value.name
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = each.value.publisher
  type                       = each.value.type
  type_handler_version       = each.value.type_handler_version
  auto_upgrade_minor_version = true
}

##############################################################
# TC-02: AADSSHLoginForLinux — enforces Entra ID + MFA login
# This extension MUST be present for MFA-only access
##############################################################

resource "azurerm_virtual_machine_extension" "aad_ssh" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
