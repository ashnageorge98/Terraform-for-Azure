resource "azurerm_resource_group" "rg" {
  name     = "my-acr-rg"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "myacrregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}
