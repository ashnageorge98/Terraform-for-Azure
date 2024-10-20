provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vmss_rg" {
  name     = "vmssResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "vmss_vnet" {
  name                = "vmssVnet"
  resource_group_name = azurerm_resource_group.vmss_rg.name
  location            = azurerm_resource_group.vmss_rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "vmss_subnet" {
  name                 = "vmssSubnet"
  resource_group_name  = azurerm_resource_group.vmss_rg.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "myVMSS"
  resource_group_name = azurerm_resource_group.vmss_rg.name
  location            = azurerm_resource_group.vmss_rg.location
  sku                 = "Standard_DS1_v2"
  instances           = 2
  admin_username      = "adminuser"
  admin_password      = "Password1234!"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "vmssNic"
    primary = true

    ip_configuration {
      name      = "vmssIpConfig"
      subnet_id = azurerm_subnet.vmss_subnet.id
    }
  }
}
