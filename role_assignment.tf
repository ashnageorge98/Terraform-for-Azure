#Role assignment links users or applications to specific roles in Azure, which grants them certain permissions.

# Provider Block: Uses the Azure RM (Resource Manager) plugin
provider "azurerm" {
  features {}
}

# Data Block: Gets information about a specific Azure AD user
data "azuread_user" "example" {
  user_principal_name = "user1@mydomain.com"                      # Fetches the user based on the email
}

# Resource Block: Assigns a role to the user
resource "azurerm_role_assignment" "example" {
  scope              = "/subscriptions/<subscription-id>"         # The scope at which the role is assigned (subscription-level in this case)
  role_definition_name = "Contributor"                            # The role being assigned, like "Contributor"
  principal_id       = data.azuread_user.example.object_id        # User's unique ID fetched using data block
}
