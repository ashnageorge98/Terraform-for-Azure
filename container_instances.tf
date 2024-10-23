resource "azurerm_resource_group" "rg" {
  name     = "my-aci-rg"
  location = "East US"
}

resource "azurerm_container_group" "aci" {
  name                = "myacigroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "mycontainer"
    image  = "nginx:latest"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = {
    environment = "dev"
  }
}
