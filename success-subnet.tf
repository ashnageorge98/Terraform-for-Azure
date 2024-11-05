provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  default = "myNewResourceGroup"  # Change this if desired
}

variable "location" {
  default = "eastus"  # Change to your preferred Azure region
}

variable "vnet_name" {
  default = "myNewVNet"  # Change to your desired VNet name
}

variable "vnet_address_space" {
  default = ["10.0.0.0/16"]  # Adjust as needed
}

# Create Resource Group
resource "azurerm_resource_group" "example_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Virtual Network
resource "azurerm_virtual_network" "example_vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  address_space       = var.vnet_address_space
}

# Create Subnets
resource "azurerm_subnet" "example_subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.example_vnet]  # Ensures VNet creation is completed first
}

resource "azurerm_subnet" "example_subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_virtual_network.example_vnet]  # Ensures VNet creation is completed first
}

resource "azurerm_subnet" "example_subnet3" {
  name                 = "subnet3"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  depends_on           = [azurerm_virtual_network.example_vnet]  # Ensures VNet creation is completed first
}
