resource "azurerm_app_service_plan" "main" {
  name = "my-app-service-plan"
  location = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "main" {
  name = "my-web-app"
  location = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.main.id
}

variable "location" {}
variable "resource_group_name" {}

output "url"
  value = azurerm_app_service.main.default_site_hostname
}
