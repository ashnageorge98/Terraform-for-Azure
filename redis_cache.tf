resource "azurerm_redis_cache" "example" {
  name                = "examplerediscache"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  capacity            = 1  # Size in GB
  family              = "C"  # Pricing tier family
  sku {
    name     = "Basic"
    tier     = "Basic"
    capacity = 1  # Size in GB
  }

  tags = {
    environment = "testing"
  }
}
