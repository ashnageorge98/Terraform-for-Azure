# Specify the required provider
provider "azurerm" {
  features {}
subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Create a virtual network (VNet)
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]  # Define the VNet address space
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define CIDR ranges for each subnet
locals {
  subnets = [
    { name = "subnet1", cidr = "10.0.1.0/24" },
    { name = "subnet2", cidr = "10.0.2.0/24" },
    { name = "subnet3", cidr = "10.0.3.0/24" },
    { name = "subnet4", cidr = "10.0.4.0/24" },
    # Add more subnets as needed
  ]
}

# Create subnets based on the CIDR ranges defined in locals
resource "azurerm_subnet" "example" {
  count                 = length(local.subnets)
  name                  = local.subnets[count.index].name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_name  = azurerm_virtual_network.example.name
  address_prefixes      = [local.subnets[count.index].cidr]
}
