# Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct" # must be unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Terraform-Blob-Storage"
  }
}

# Storage Container (Blob)
resource "azurerm_storage_container" "example" {
  name                  = "example-container"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"  # Change to "blob" for public access
}

# Output the storage account name and container
output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

output "storage_container_name" {
  value = azurerm_storage_container.example.name
}
