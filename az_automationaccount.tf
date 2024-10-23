provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "East US"
}

resource "azurerm_automation_account" "example" {
  name                = "example-automation-account"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Basic"

  tags = {
    environment = "testing"
  }
}

Notes:
resource "azurerm_automation_account" "example" { ... }
This block defines a new Azure Automation Account named "example-automation-account". This account can manage automation tasks such as runbooks.

tags = { environment = "testing" }
This block allows you to assign metadata to your resources. Here, the tag indicates that this resource is for testing purposes.
