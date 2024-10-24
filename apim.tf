# secure and manage api im dev before moving to qa or prod.
Real-World DevOps Use Case:
In a DevOps pipeline, the APIM instance and its APIs are deployed in a development environment (using the Developer SKU for cost-saving).
DevOps engineers manage this through Terraform, automating API deployment, updates, and lifecycle management (such as scaling or applying security policies).
APIs undergo versioning and testing in a Dev environment before promotion to QA and Production.
Security policies, including OAuth, rate-limiting, and logging, can be added to the APIM instance after deployment.


# Step 1: Define the provider
provider "azurerm" {
  features {}
}

# Step 2: Define Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-apim-devops"
  location = "East US"
}

# Step 3: Define an API Management Service
resource "azurerm_api_management" "apim" {
  name                = "devops-apim-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "DevOps Team"
  publisher_email     = "devops@example.com"
  sku_name            = "Developer_1"  # Dev environment - cheaper SKU
  identity {
    type = "SystemAssigned"
  }
  tags = {
    environment = "dev"
    department  = "DevOps"
  }
}

# Step 4: Define a Virtual Network for APIM (optional but recommended in real-world)
resource "azurerm_virtual_network" "vnet" {
  name                = "apim-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "apim-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_api_management_virtual_network_configuration" "vnet_config" {
  api_management_id = azurerm_api_management.apim.id
  subnet_id         = azurerm_subnet.subnet.id
}

# Step 5: Define a Sample API within the APIM instance
resource "azurerm_api_management_api" "sample_api" {
  name                = "sample-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Sample API"
  path                = "sample"
  protocols           = ["https"]
}

# Step 6: Define an API Operation
resource "azurerm_api_management_api_operation" "get_operation" {
  operation_id        = "getSampleData"
  api_name            = azurerm_api_management_api.sample_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get Sample Data"
  method              = "GET"
  url_template        = "/data"
  response {
    status  = 200
    description = "Success"
    representations {
      content_type = "application/json"
    }
  }
}
