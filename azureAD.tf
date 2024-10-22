provider "azuread" {
tenant_id = "<your-tenant-id>"                         # Azure Ad Tenant ID

# Resource Block: Defines a new Azure AD group
resource "azuread_group" "example" {
display_name = "examplegroup"                          #name of AD group
security_enabled = true                                #Set to true to make it a security group
}

#Resource Block: Defines a new Azure AD user
resource "azuread_user" "example" {
  user_principal_name = "user1@mydomain.com"           # Email address of the user
  display_name        = "User One"                     # User's display name
  password            = "SuperSecretPassword1"         # User password
}

# Resource Block: Defines a new Azure AD application
resource "azuread_application" "example" {
  display_name = "ExampleApp"                          # Application name
}
