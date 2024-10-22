provider "azurerm" {
  features {}
}

# Create a storage account
resource "azurerm_storage_account" "example" {
  name                     = "examplestoracc123"  # Storage account name must be unique globally
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Locally-redundant storage

  tags = {
    environment = "Dev"
    project     = "Storage"
  }
}

# Create a storage container in the storage account
resource "azurerm_storage_container" "example" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}
