#Managed Identities are special identities in Azure used to give resources like VMs, containers, 
or other Azure services access to Azure resources without needing to store credentials/secrets.

# Specify the Azure provider for Terraform
provider "azurerm" {
  features {}                         # Enables Azure Resource Manager (azurerm) features. Required for Terraform to use the provider.
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"  # Specifies the Azure subscription ID for resource management.
}

# Resource group to contain the managed identity resources
resource "azurerm_resource_group" "example" {
  name     = "example-resources"      # Name of the resource group, which organizes related resources in Azure.
  location = "East US"                # Specifies the Azure region (location) where the resource group will be created.
}

# Defines a user-assigned managed identity, allowing Azure resources to access other resources securely
resource "azurerm_user_assigned_identity" "example_identity" {
  name                = "example-managed-identity"       # Name for the managed identity, unique within the resource group.
  location            = azurerm_resource_group.example.location  # Uses the location of the previously defined resource group.
  resource_group_name = azurerm_resource_group.example.name      # Links the identity to the resource group created above.
}

# Assigns a specific role to the managed identity, granting permissions within a defined scope
resource "azurerm_role_assignment" "example_role_assignment" {
  scope                 = "/subscriptions/81b0b41e-5edd-4af2-86ea-1b1457a4374c"  # Scope for the role assignment; here, the subscription level.
  role_definition_name  = "Contributor"                                           # Role assigned to the managed identity, e.g., "Contributor" grants create, update, and delete permissions.
  principal_id          = azurerm_user_assigned_identity.example_identity.principal_id  # Managed identity’s principal ID, used to link the identity with the role assignment.
}

# Outputs the managed identity ID, which can be used as a reference in other configurations or scripts
output "managed_identity_id" {
  value = azurerm_user_assigned_identity.example_identity.id  # Returns the unique ID of the managed identity.
}

