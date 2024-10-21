resource "azurerm_lb" "example_lb" {
  name                = "example-lb"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontendConfig"
    subnet_id            = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
