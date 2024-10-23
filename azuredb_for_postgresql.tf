resource "azurerm_postgresql_server" "example" {
  name                         = "examplepgserver"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "11"
  administrator_login          = "pgadmin"
  administrator_login_password = "P@ssw0rd1234!"          # Use a secure password in real applications

  sku {
    name     = "B_Gen5_1"
    tier     = "Basic"
    capacity = 1  # Size in vCores
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_postgresql_database" "example" {
  name                = "examplepgdb"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "utf8"
  collation           = "en_US.UTF-8"

  tags = {
    environment = "testing"
  }
}

#Azure DB for MySQL server
resource "azurerm_mysql_server" "example" {
  name                         = "examplemysqlserver"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "5.7"
  administrator_login          = "mysqladmin"
  administrator_login_password = "P@ssw0rd1234!"  # Use a secure password in real applications

  sku {
    name     = "B_Gen5_1"
    tier     = "Basic"
    capacity = 1  # Size in vCores
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_mysql_database" "example" {
  name                = "examplemysqldb"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  charset             = "utf8"
  collation           = "en_US.UTF-8"

  tags = {
    environment = "testing"
  }
}

Notes:
In real applications, avoid hardcoding sensitive data like passwords. Use Azure Key Vault or 
environment variables to manage secrets securely.
