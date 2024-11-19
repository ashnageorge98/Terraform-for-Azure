# Set the provider
provider "azurerm" {
  features {}
}

# Define variables for reusability
variable "resource_group_name" {
  default = "my-resource-group"
}

variable "location" {
  default = "East US"
}

variable "sql_server_name" {
  default = "my-sql-server-123"
}

variable "sql_database_name" {
  default = "my-sql-database"
}

variable "admin_username" {
  default = "sqladminuser"
}

variable "admin_password" {
  default = "P@ssw0rd123!" # Note: Use a secret management tool in real cases
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  version                      = "12.0" # SQL Server version
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name                = var.sql_database_name
  server_id           = azurerm_mssql_server.main.id
  sku_name            = "S1"         # Pricing tier (Standard S1 as an example)
  max_size_gb         = 10           # Maximum database size
  collation           = "SQL_Latin1_General_CP1_CI_AS" # Default collation
  license_type        = "LicenseIncluded" # Default license type
  zone_redundant      = false
  auto_pause_delay_in_minutes = 60  # Use for serverless databases (optional)
}

# Firewall Rules
resource "azurerm_sql_firewall_rule" "allow_all_azure_services" {
  name                = "AllowAzureServices"
  server_name         = azurerm_mssql_server.main.name
  resource_group_name = azurerm_resource_group.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_firewall_rule" "allow_my_ip" {
  name                = "AllowMyIP"
  server_name         = azurerm_mssql_server.main.name
  resource_group_name = azurerm_resource_group.main.name
  start_ip_address    = "123.123.123.123" # Replace with your IP
  end_ip_address      = "123.123.123.123"
}

# Outputs
output "sql_server_name" {
  value = azurerm_mssql_server.main.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.main.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}
