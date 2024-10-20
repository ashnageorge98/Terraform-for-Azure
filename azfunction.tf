provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "function_rg" {
  name     = "functionAppResourceGroup"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "mystorageacctfunc"
  resource_group_name      = azurerm_resource_group.function_rg.name
  location                 = azurerm_resource_group.function_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "function_plan" {
  name                = "functionAppPlan"
  location            = azurerm_resource_group.function_rg.location
  resource_group_name = azurerm_resource_group.function_rg.name
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "myFunctionApp"
  location                   = azurerm_resource_group.function_rg.location
  resource_group_name        = azurerm_resource_group.function_rg.name
  os_type                    = "Linux"
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  app_service_plan_id        = azurerm_app_service_plan.function_plan.id

  site_config {
    linux_fx_version = "Python|3.8"
  }
}
