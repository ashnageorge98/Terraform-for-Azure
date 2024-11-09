# Configure the Azure provider
provider "azurerm" {
  features {}
subscription_id   =    "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Resource group for SQL Server and Database
variable "resource_group_name" {
  default = "RG1"
}

# Data source to reference the existing resource group
data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

# Azure SQL Server
resource "azurerm_mssql_server" "example" {
  name                         = "example-mssql-server"
  resource_group_name          = data.azurerm_resource_group.example.name
  location                     = data.azurerm_resource_group.example.location  # Reference the location dynamically
  version                      = "12.0"                            # SQL Server version
  administrator_login          = "sqladminuser"                    # Admin username
  administrator_login_password = "P@ssw0rd123!"                    # Admin password, consider using secrets

  # Connection policies for serverless access, defaults to 'Default'
  connection_policy            = "Default"

  # Tags (Optional)
  tags = {
    environment = "Development"
    project     = "MSSQL-Project"
  }
}

# SQL Server Firewall Rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  server_id            = azurerm_mssql_server.example.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# SQL Server Firewall Rule to allow specific IP range (Optional)
resource "azurerm_mssql_firewall_rule" "allow_specific_ip_range" {
  name                = "AllowSpecificIPRange"
  server_id           = azurerm_mssql_server.example.id
  start_ip_address    = "192.168.1.1"
  end_ip_address      = "192.168.1.255"
}


# Azure SQL Database inside the SQL Server
resource "azurerm_mssql_database" "example" {
  name                = "example-mssql-database"
  server_id           = azurerm_mssql_server.example.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"             # Database collation
  max_size_gb         = 1
  sku_name            = "S0"

  # Tags (Optional)
  tags = {
    environment = "Development"
    project     = "ExampleProject"
  }
}

# Optional: Azure AD Administrator for SQL Server
# This resource is commented out since it may be unsupported in some provider versions.
# Uncomment and replace values if supported by your provider version.

# resource "azurerm_sql_active_directory_administrator" "example" {
#   server_name         = azurerm_mssql_server.example.name
#   resource_group_name = data.azurerm_resource_group.example.name  # Reference the same RG
#   login               = "aad-admin-user"
#   object_id           = "aad-user-object-id"    # Replace with actual AD user or group object ID
#   tenant_id           = "aad-tenant-id"         # Replace with actual tenant ID
# }

# Optional: Setup for Geo-Replication with a Secondary Database
# Uncomment and replace with secondary server setup if required by your configuration.

# resource "azurerm_mssql_database" "example_replica" {
#   name       = azurerm_mssql_database.example.name
#   server_id  = "secondary-server-id"             # Replace with actual secondary server ID
#   collation  = azurerm_mssql_database.example.collation
#   sku_name   = azurerm_mssql_database.example.sku_name
#   create_mode = "Secondary"                      # Specify as a replica database
#   location   = data.azurerm_resource_group.example.location  # Use the location dynamically                         # Location for secondary region

#   tags = {
#     environment = "Development"
#     project     = "ExampleProject"
#   }
# }
