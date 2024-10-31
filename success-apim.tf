# apim instances will secure and manage api in dev before promoting to qa and prod.
Real-World DevOps Use Case:
In a DevOps pipeline, the APIM instance and its APIs are deployed in a development environment (using the Developer SKU for cost-saving).
DevOps engineers manage this through Terraform, automating API deployment, updates, and lifecycle management (such as scaling or applying security policies).
APIs undergo versioning and testing in a Dev environment before promotion to QA and Production.
Security policies, including OAuth, rate-limiting, and logging, can be added to the APIM instance after deployment.

# Step 1: Define the provider
provider "azurerm" {
  features {}
  alias           = "apim"
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Step 2: Define Resource Group
resource "azurerm_resource_group" "rg" {
  provider = azurerm.apim
  name     = "rg-apim-devops"
  location = "East US"
}

# Step 3: Define a Virtual Network for APIM
resource "azurerm_virtual_network" "vnet" {
  name                = "apim-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Step 4: Define a Subnet for APIM
resource "azurerm_subnet" "subnet" {
  name                 = "apim-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Step 5: Define a Network Security Group for APIM subnet
resource "azurerm_network_security_group" "apim_nsg" {
  name                = "apim-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHttpsInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Step 6: Associate the Network Security Group with the Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.apim_nsg.id
}

# Step 7: Define an API Management Service
resource "azurerm_api_management" "apim" {
  name                = "devops-apim-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "Ashna DevOps"
  publisher_email     = "ashnageorge98@gmail.com"

  virtual_network_type = "Internal" # Set to Internal for private access

  virtual_network_configuration {
    subnet_id = azurerm_subnet.subnet.id  # Reference the subnet
  }

  sku_name            = "Developer_1"  # Dev environment - cheaper SKU

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
    department  = "DevOps"
  }
}

# Step 8: Define a Sample API within the APIM instance
resource "azurerm_api_management_api" "sample_api" {
  name                = "sample-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "Sample API"
  path                = "sample"
  revision            = "1"
  protocols           = ["https"]
}

# Step 9: Define an API Operation
resource "azurerm_api_management_api_operation" "get_operation" {
  operation_id        = "getSampleData"
  api_name            = azurerm_api_management_api.sample_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get Sample Data"
  method              = "GET"
  url_template        = "/data"
  
  response {
    status_code  = 200

    representation {
      content_type = "application/json"
    }
  }
}
