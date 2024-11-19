
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Reference existing resource group
data "azurerm_resource_group" "existing" {
  name = "RG1"
}

# 2. Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-databricks-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# 3. Create Subnets
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegations {
    name = "databricks_delegation"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      ]
    }
  }
}

# 4. Create Azure Databricks Workspace
resource "azurerm_databricks_workspace" "example" {
  name                = "databricks-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "premium"

  managed_resource_group_id = azurerm_resource_group.example.id
  custom_virtual_network_id = azurerm_virtual_network.example.id
  public_subnet_name        = azurerm_subnet.public_subnet.name
  private_subnet_name       = azurerm_subnet.private_subnet.name
}

# 5. Output values for verification
output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.example.workspace_url
}

output "databricks_workspace_id" {
  value = azurerm_databricks_workspace.example.id
}
