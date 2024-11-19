terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.7" # Use the latest compatible version
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Define variables for reusable values
variable "location" {
  default = "East US"
}

variable "vnet_name" {
  default = "ase-vnet"
}

variable "subnet_name" {
  default = "ase-subnet"
}

variable "ase_name" {
  default = "my-ase"
}

variable "app_service_plan_name" {
  default = "my-app-service-plan"
}

variable "sku_name" {
  default = "I1" # I1 for basic pricing (can be adjusted as per your requirement)
}

variable "ase_vnet_integration" {
  default = "true"
}

# Reference the existing Resource Group (RG1)
data "azurerm_resource_group" "existing" {
  name = "RG1"
}

# Virtual Network for ASE (within the existing resource group)resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for ASE (ASE requires specific subnet for deployment)
resource "azurerm_subnet" "ase_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints = ["Microsoft.Web"]
}

# App Service Environment
resource "azurerm_app_service_environment_v3" "main" {
  name                = var.ase_name
  resource_group_name = data.azurerm_resource_group.existing.name
  subnet_id           = azurerm_subnet.ase_subnet.id

  # Optional settings
  zone_redundant              = false
}

# App Service Plan (this is linked to ASE)
resource "azurerm_app_service_plan" "main" {
  name                = var.app_service_plan_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  kind                = "Windows"
  reserved            = true
  sku {
    tier = "IsolatedV2"
    size = "I1v2"
  }
}

# Public IP for the ASE
resource "azurerm_public_ip" "ase_public_ip" {
  name                         = "ase-public-ip"
  resource_group_name          = data.azurerm_resource_group.existing.name
  location                     = data.azurerm_resource_group.existing.location
  ip_version                   = "IPv4"
  allocation_method            = "Static"
  idle_timeout_in_minutes      = 4
  sku                          = "Standard"
}# Application Gateway (Optional, for advanced scenarios)
resource "azurerm_application_gateway" "main" {
  name                     = "my-application-gateway"
  location                 = data.azurerm_resource_group.existing.location
  resource_group_name      = data.azurerm_resource_group.existing.name

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    capacity = 2
  }

gateway_ip_configuration {
  name = "example-gateway-ip-config"
  subnet_id = azurerm_subnet.ase_subnet.id
}

# Frontend IP Configuration
frontend_ip_configuration {
  name = "appgateway-frontend-ip"
  public_ip_address_id = azurerm_public_ip.ase_public_ip.id
}

frontend_port {
  name = "example-frontebd-port"
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
    frontend_ip_configuration_name = "example-frontend-ip"
    frontend_port_name             = "example-frontend-port"
    protocol                       = "Http"
  }

  # Request Routing Rule
  request_routing_rule {
    name                       = "routing-rule"    rule_type                  = "Basic"
    http_listener_name         = "example-http-listener"
    backend_address_pool_name  = "example-backend-pool"
    backend_http_settings_name = "example-backend-http-settings"
  }
}

# Create an Application Service within the ASE (Optional)
resource "azurerm_windows_web_app" "main" {
  name                = "my-web-app"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  service_plan_id     = azurerm_app_service_plan.main.id

  site_config {
}

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}
