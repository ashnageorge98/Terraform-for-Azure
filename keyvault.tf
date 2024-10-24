# Securely storing secrets such as API keys, connection strings, certificates, etc

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-devops-keyvault"
  location = "East US"
}

resource "azurerm_key_vault" "example" {
  name                        = "devopskeyvault123"            # Key Vault name must be globally unique.
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  tenant_id                   = data.azurerm_client_config.example.tenant_id
  sku_name                    = "standard"                     # Standard or Premium
  soft_delete_enabled         = true                           # Enables recovery for deleted keys.
  purge_protection_enabled    = true                           # Prevents immediate deletion, enforcing retention.

  network_acls {
    default_action = "Deny"                                    # Default deny all network traffic.
    bypass         = "AzureServices"                           # Allows trusted Azure services to bypass ACLs.
    ip_rules       = ["123.123.123.123"]                       # Allow this specific IP to access the vault.
  }

  tags = {
    environment = "dev"
    owner       = "devops-team"
  }
}

resource "azurerm_key_vault_secret" "example" {
  name         = "db-connection-string"
  value        = "Server=tcp:myserver.database.windows.net,1433;Initial Catalog=mydb;User ID=myuser;Password=mypassword;"
  key_vault_id = azurerm_key_vault.example.id
}

data "azurerm_client_config" "example" {}


 Real-Time Use Case in a DevOps Pipeline:
In a DevOps workflow, you might use this Key Vault for various purposes:

1. Storing sensitive data: The database connection string (or any API keys) stored in the Key Vault can be accessed by your applications in a secure manner.
2. Integration with CI/CD: Tools like Azure DevOps, Jenkins, or GitHub Actions can fetch secrets from the Key Vault during build or deployment pipelines
to avoid hardcoding sensitive credentials in pipeline code.
    Example: A pipeline task to deploy an app could fetch the db-connection-string secret from the Key Vault and use it during the application deployment.
3. Network security: Only specific trusted Azure services (like Azure DevOps or Application Insights) and certain IP addresses can access the Key Vault, ensuring that sensitive data is protected from unwanted access.
