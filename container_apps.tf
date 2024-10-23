# container_apps.tf

# Step 1: Define provider
provider "azurerm" {
  features {}
}

# Step 2: Resource group (reuse)
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}

# Step 6: Azure Container App Environment
resource "azurerm_container_app_environment" "app_env" {
  name                = "myContainerAppEnv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Step 7: Azure Container App
resource "azurerm_container_app" "app" {
  name                = "myContainerApp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  container_app_environment_id = azurerm_container_app_environment.app_env.id

  template {
    container {
      name   = "myapp"
      image  = "nginx"
      cpu    = "0.25"
      memory = "0.5Gi"
    }
ingress {
      external_enabled = true
      target_port      = 80
    }
  }
}

# Output - Container App URL
output "container_app_fqdn" {
  value = azurerm_container_app.app.latest_revision_fqdn
}
