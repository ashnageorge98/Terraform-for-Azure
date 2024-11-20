#Azure Active Directory (AAD) is the directory service that stores information about users, groups, and applications.
Creates users, groups, and applications in Azure Active Directory.

# Provider Block: This tells Terraform to use the Azure AD plugin

# Configure the Azure and AzureAD providers

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0" # Use appropriate version
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.7" # Use appropriate version
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

provider "azuread" {
  tenant_id = var.tenant_id
}

# Variables
variable "tenant_id" {
  description = "The Azure AD Tenant ID"
  type        = string
}

variable "admin_user_password" {
  description = "Password for the admin user"
  type        = string
  sensitive   = true
}

variable "app_display_name" {
  description = "The display name for the Azure AD Application"
  type        = string
  default     = "MyApp"
}

# Create an Azure AD User
resource "azuread_user" "example_user" {
  user_principal_name = "adminuser@mytenant.onmicrosoft.com"
  display_name        = "Admin User"
  mail_nickname       = "adminuser"
  password            = var.admin_user_password
  force_password_change = false
}

# Create an Azure AD Group
resource "azuread_group" "example_group" {
  display_name     = "Developers Group"
  description      = "Group for development team"
  security_enabled = true
}

# Add User to Group
resource "azuread_group_member" "group_member" {
  group_object_id = azuread_group.example_group.id
  member_object_id = azuread_user.example_user.id
}

# Create an Azure AD Application
resource "azuread_application" "example_app" {
  display_name     = var.app_display_name
  sign_in_audience = "AzureADMyOrg" # Options: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount
}

# Create a Service Principal for the Application
resource "azuread_service_principal" "example_sp" {
  application_id = azuread_application.example_app.application_id
}

# Assign a Role to the Service Principal
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "example_assignment" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Contributor" # Change role as needed
  principal_id         = azuread_service_principal.example_sp.object_id
}

# Output Values
output "user_principal_name" {
  value = azuread_user.example_user.user_principal_name
}

output "group_id" {
  value = azuread_group.example_group.id
}

output "application_id" {
  value = azuread_application.example_app.application_id
}

output "service_principal_id" {
  value = azuread_service_principal.example_sp.object_id
}



