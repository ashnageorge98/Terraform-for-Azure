# main.tf

# Provider Configuration
provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Use existing Resource Group
data "azurerm_resource_group" "existing" {
  name     = "RG1"
}

# Define Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "uniquename1029" # must be globally unique
  resource_group_name      = data.azurerm_resource_group.existing.name
  location                 = data.azurerm_resource_group.existing.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Access configuration
  min_tls_version           = "TLS1_2"

  # Blob Properties
  blob_properties {
    delete_retention_policy {
      days = 7 # Retain deleted blobs for 7 days
    }
  }

  # Network Rules
  network_rules {
    default_action   = "Allow"
    ip_rules         = ["100.100.100.100"] # Allow specific IP, modify as needed
    bypass           = ["AzureServices"]
  }

  # Tags
  tags = {
    environment = "development"
    project     = "ExampleProject"
  }
}

# Define Blob Container
resource "azurerm_storage_container" "example" {
  name                  = "example-container"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private" # Options: private, blob, container
}

# Using data source for (storage account)SAS token instead of resource
data "azurerm_storage_account_sas" "example" {
  connection_string = azurerm_storage_account.example.primary_connection_string
  https_only              = true
  start                   = "2023-01-01"
  expiry                  = "2023-12-31"

# Permissions block - specify all required permissions
permissions {
  read = true
  add = true
  create = true
  write = true
  delete = true
  list = true
  tag = false
  update = false
  filter = false
  process = false
}

# Services block -  specify all available services
services {
  blob = true
  file = false
  queue = false
  table = false
}

# Resource_type block - specify all types of resources the SAS token can access
resource_types {
  service   = true
  container = true
  object    = true
}
}

# Optional: Shared Access Signature URL output for convenience
output "sas_url" {
  value = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}?${data.azurerm_storage_account_sas.example.sas}"
  sensitive = true
}

# Optional: Outputs for debugging or further use
output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

output "storage_account_primary_access_key" {
  value     = azurerm_storage_account.example.primary_access_key
  sensitive = true
}

output "container_url" {
  value = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}"
}
