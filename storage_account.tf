provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"              # Name of the storage account (must be globally unique)
  resource_group_name       = "myresourcegroup"              # Name of the resource group where this storage account will be created
  location                  = "East US"                      # Azure region where the storage account is located
  account_tier              = "Standard"                     # Pricing tier (Standard or Premium)
  account_replication_type  = "LRS"                          # Replication type: Local Redundant Storage (LRS)
}

