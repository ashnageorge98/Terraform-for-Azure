provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source              = "../modules/vnet"
  vnet_name           = "myVNet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

module "subnet" {
  source              = "../modules/subnet"
  subnet_name         = "mySubnet"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = module.vnet.vnet_id
  address_prefix      = "10.0.1.0/24"
}

module "vm" {
  source                = "../modules/vm"
  vm_name               = "myVM"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  vm_size               = "Standard_DS1_v2"
  admin_username        = "adminuser"
  ssh_key               = file("~/.ssh/id_rsa.pub")
  network_interface_id  = module.subnet.subnet_id
}
