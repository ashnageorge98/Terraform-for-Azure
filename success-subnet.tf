provider "azurerm" {
  features {}
subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Variables for existing resources
variable "resource_group_name" {
  default = "myResourceGroup"
}

variable "location" {
  default = "eastus" # Change to your desired location
}

variable "vnet_name" {
  default = "myVNet"
}

variable "vnet_address_space" {
  default = ["10.0.0.0/16"] # Adjust as needed
}

# Define the resource group
resource "azurerm_resource_group" "example_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Define the virtual network
resource "azurerm_virtual_network" "example_vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  address_space       = var.vnet_address_space
}

# Define subnets
resource "azurerm_subnet" "example_subnet1" {
  name                 = "subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.1.0/24"]  # Adjust as needed
}

resource "azurerm_subnet" "example_subnet2" {
  name                 = "subnet2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.2.0/24"]  # Adjust as needed
}

resource "azurerm_subnet" "example_subnet3" {
  name                 = "subnet3"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.3.0/24"]  # Adjust as needed
}
