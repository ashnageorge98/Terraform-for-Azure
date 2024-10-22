#Managed Identities are special identities in Azure used to give resources like VMs, containers, 
or other Azure services access to Azure resources without needing to store credentials.

# Resource Block: Creates a user-assigned managed identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "exampleIdentity"       # Name of the managed identity
  location            = "East US"               # Azure region
  resource_group_name = "<your-resource-group>"  # Resource group for the managed identity
}

# Resource Block: Assigns a role to the managed identity
resource "azurerm_role_assignment" "example" {
  scope              = "/subscriptions/<subscription-id>"  # Scope for the role assignment
  role_definition_name = "Contributor"  # Role assigned to the managed identity, like "Contributor"
  principal_id       = azurerm_user_assigned_identity.example.principal_id  # Managed Identity's principal ID
}
