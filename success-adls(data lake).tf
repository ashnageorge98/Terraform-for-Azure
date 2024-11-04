
# Required Terraform Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US" # Change to your desired location
}

# Create a Storage Account with Hierarchical Namespace Enabled
resource "azurerm_storage_account" "example" {
  name                     = "examplestoracc" # Must be globally unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Locally Redundant Storage

  is_hns_enabled           = true  # Enable Hierarchical Namespace

  tags = {
    environment = "example"
  }
}

# Optional: Create a File System in the Storage Account
resource "azurerm_storage_data_lake_gen2_filesystem" "example" {
  name               = "example-filesystem" # Must be globally unique
  storage_account_id = azurerm_storage_account.example.id
}

# Output the Storage Account and File System URLs
output "storage_account_url" {
  value = azurerm_storage_account.example.primary_blob_endpoint
}

output "file_system_url" {
  value = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_data_lake_gen2_filesystem.example.name}/"
}
