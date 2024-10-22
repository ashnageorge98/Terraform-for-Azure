resource "azurerm_cosmosdb_account" "example" {
  name                = "example-cosmosdb"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  offer_type         = "Standard"
  kind               = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  tags = {
    environment = "testing"
  }
}

--
kind = "GlobalDocumentDB": This indicates the type of Cosmos DB account being created. "GlobalDocumentDB" is used for applications that require global distribution
and supports the document database model (like JSON data).
"Session" means that a session (like a user's session) will see the most recent writes made by that session, providing a balance between consistency and performance
