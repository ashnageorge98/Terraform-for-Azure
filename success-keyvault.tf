# Securely storing secrets such as API keys, connection strings, certificates, etc
# The Azure Key Vault is used to store sensitive information like passwords, certificates, or secrets.

--
# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Define variables (optional)
variable "resource_group_name" {
  description = "The name of the resource group in which the Key Vault will be created."
  type        = string
}

variable "location" {
  description = "The Azure location for the Key Vault."
  type        = string
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
}

# Resource Group (if you need to create one)
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Key Vault
resource "azurerm_key_vault" "example" {
 name                        = var.key_vault_name
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.example.tenant_id
  purge_protection_enabled    = false # Enable if you want to protect resources from being deleted permanently
  enable_rbac_authorization   = true  # Enables Azure RBAC on Key Vault

  # Access policy example (optional)
  access_policy {
    tenant_id = data.azurerm_client_config.example.tenant_id
    object_id = data.azurerm_client_config.example.object_id

    # Define permissions
    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete"
    ]
     secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Create",
      "Delete"
    ]
  }

  # Network access rules (optional)
  network_acls {
    default_action = "Deny" # Deny by default, and allow specific networks
    bypass         = "AzureServices"

    # Allow from specific IP addresses
    ip_rules = ["123.123.123.123"]

    # Allow access from specific virtual networks
    virtual_network_subnet_ids = [
      azurerm_subnet.example.id # Add subnet IDs if needed
    ]
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
    owner       = "devops-team"
  }
}

# Data for tenant and object ID
data "azurerm_client_config" "example" {}

# Example Virtual Network (Optional)
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
 resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

# Add service endpoints for Key Vault
  service_endpoints = ["Microsoft.KeyVault"]
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.example.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.example.vault_uri
}

--
 Real-Time Use Case in a DevOps Pipeline:
In a DevOps workflow, you might use this Key Vault for various purposes:

1. Storing sensitive data: The database connection string (or any API keys) stored in the Key Vault can be accessed by your applications in a secure manner.
2. Integration with CI/CD: Tools like Azure DevOps, Jenkins, or GitHub Actions can fetch secrets from the Key Vault during build or deployment pipelines
to avoid hardcoding sensitive credentials in pipeline code.
    Example: A pipeline task to deploy an app could fetch the db-connection-string secret from the Key Vault and use it during the application deployment.
3. Network security: Only specific trusted Azure services (like Azure DevOps or Application Insights) and certain IP addresses can access the Key Vault, ensuring that sensitive data is protected from unwanted access.
