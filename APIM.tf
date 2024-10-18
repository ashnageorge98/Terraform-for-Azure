# apim.tf

# Step 1: Define provider
provider "azurerm" {
  features {}
}

# Step 2: Resource group (reuse)
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}

# Step 4: Subnet for APIM (reuse AKS subnet)
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Step 8: Azure API Management (APIM)
resource "azurerm_api_management" "apim" {
  name                = "myAPIMService"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "myemail@domain.com"
  publisher_email     = "myemail@domain.com"
  sku_name            = "Developer_1"

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = azurerm_subnet.aks_subnet.id
  }
}

# Output - APIM Details
output "apim_url" {
  value = azurerm_api_management.apim.gateway_url
}
