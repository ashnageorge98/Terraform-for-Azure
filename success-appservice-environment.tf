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

# Define variables
variable "location" { default = "East US" }
variable "vnet_name" { default = "ase-vnet" }
variable "subnet_name" { default = "ase-subnet" }
variable "ase_name" { default = "my-aseunique12" }
variable "app_service_plan_name" { default = "my-app-service-plan" }

# Reference existing resource group
data "azurerm_resource_group" "existing" {
  name = "RG1"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "ase_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Web"]
}

# App Service Environment
resource "azurerm_app_service_environment_v3" "main" {
  name                = var.ase_name
  resource_group_name = data.azurerm_resource_group.existing.name
  subnet_id           = azurerm_subnet.ase_subnet.id
  zone_redundant      = false
}

# Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  os_type             = "Windows" # Or "Linux" as needed
  sku_name            = "I1"
  app_service_environment_id = azurerm_app_service_environment_v3.main.id
}

# Public IP
resource "azurerm_public_ip" "ase_public_ip" {
  name                = "ase-public-ip"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "my-application-gateway"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "example-gateway-ip-config"
    subnet_id = azurerm_subnet.ase_subnet.id
  }

  frontend_ip_configuration {
    name                 = "appgateway-frontend-ip"
    public_ip_address_id = azurerm_public_ip.ase_public_ip.id
  }

  frontend_port {
    name = "example-frontend-port"
    port = 80
  }

  backend_address_pool {
    name = "example-backend-pool"
  }

  backend_http_settings {
    name                  = "example-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "example-http-listener"
    frontend_ip_configuration_name = "appgateway-frontend-ip"
    frontend_port_name             = "example-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "example-http-listener"
    backend_address_pool_name  = "example-backend-pool"
    backend_http_settings_name = "example-backend-http-settings"
    priority                   = 100
  }
}

# Web App
resource "azurerm_windows_web_app" "main" {
  name                = "my-web-app"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on = true
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}
