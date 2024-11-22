# Required providers
provider "azurerm" {
  features {}
}

# Resource group definition
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet (used for private endpoint)
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  enforce_private_link_endpoint_network_policies = true # Enabling private link policies
}

# A Sample Azure Service (e.g., Storage Account)
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Private Endpoint
resource "azurerm_private_endpoint" "example" {
  name                = "example-private-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                           = "example-connection"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"] # This specifies the sub-resource (e.g., blob in storage)
  }
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# DNS Zone Association
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Private DNS A Record for Storage Account
resource "azurerm_private_dns_a_record" "example" {
  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.example.private_ip_address]
}
