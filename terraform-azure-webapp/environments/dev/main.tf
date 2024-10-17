provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "my-resource-group"
  location= "East US"
}

module "web_app" {
  source = "../modules/web_app"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
}

output "web_app_url" {
  value = module.web_app.url
}
