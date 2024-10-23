# The Azure Key Vault is used to store sensitive information like passwords, certificates, or secrets.

# Provider Configuration
provider "azurerm" {
  features {}
}

# Create a Resource Group for Key Vault
resource "azurerm_resource_group" "rg" {
  name     = "rg-keyvault-example"
  location = "East US"
}

# Create Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "examplekeyvault"
  location                    = "EastUS"
  resource_group_name         = "RG1"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  # Access policies - who can access the Key Vault
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["get", "list", "set", "delete"]
  }
}

# Data source to get current Azure client config
data "azurerm_client_config" "current" {}
