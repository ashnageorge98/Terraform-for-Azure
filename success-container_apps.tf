# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-container-apps"
  location = "East US"
}

# Create an Azure Container Apps Environment
resource "azurerm_container_app_environment" "example" {
  name                = "container-app-env"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-analytics-workspace"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create the Container App with minimal configuration
resource "azurerm_container_app" "example" {
  name                        = "my-container-app"
  resource_group_name         = azurerm_resource_group.example.name
  container_app_environment_id = azurerm_container_app_environment.example.id
  revision_mode               = "Multiple"  # Set this directly under azurerm_container_app

  template {
    # Configuration for the containers inside the app
    container {
      name   = "myapp-container"
      image  = "nginx:latest"  # Example: Replace this with your actual image.
      cpu    = 0.5
      memory = "1.0Gi"

      # Environment variables passed to the container
      env {
        name  = "ENVIRONMENT"
        value = "dev"
      }
    }
  }
}                                                      
