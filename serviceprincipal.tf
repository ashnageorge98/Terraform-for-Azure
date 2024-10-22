#A Service Principal allows applications or automation tools to access Azure resources.

# Resource Block: Creates an Azure AD service principal from an application
resource "azuread_service_principal" "example" {
  application_id = azuread_application.example.application_id           # Links the service principal to the application
}

# Resource Block: Assigns a role to the service principal
resource "azurerm_role_assignment" "example" {
  scope              = "/subscriptions/<subscription-id>"               # Scope for the role assignment
  role_definition_name = "Reader"                                       # Role assigned to the service principal, like "Reader"
  principal_id       = azuread_service_principal.example.id 
}
