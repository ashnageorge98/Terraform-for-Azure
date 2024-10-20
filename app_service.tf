provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app_rg" {
  name     = "appServiceResourceGroup"
  location = "East US"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "appServicePlan"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "myWebApp"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "PYTHON|3.8"
  }
}
