
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "East US"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "example-logic-app"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  definition          = jsonencode({
    "$schema" = "http://schema.management.azure.com/schemas/2016-06-01/workflowdefinition.json#",
    "actions" = {
      "http_request" = {
        "inputs" = {
          "method" = "GET",
          "uri"    = "https://api.example.com/data"
        },
        "runAfter" = {},
        "type"     = "Http"
      }
    },
    "triggers" = {
      "manual" = {
        "inputs" = {},
        "kind"   = "Http",
        "type"   = "Request"
      }
    }
  })
}

Notes:
resource "azurerm_logic_app_workflow" "example" { ... }
This block defines a new Azure Logic App workflow named "example-logic-app". Logic Apps help automate workflows by connecting various services.

definition = jsonencode({ ... })
This line provides the configuration of the Logic App in JSON format, which defines how the workflow operates.

"$schema" = "http://schema.management.azure.com/schemas/2016-06-01/workflowdefinition.json#"
Specifies the schema for the Logic App workflow definition.

"actions" = { ... }
This block defines actions that the Logic App will perform. In this example, it performs an HTTP GET request.

"http_request" = { ... }
Names the action as "http_request".

"inputs" = { ... }
   Contains the details of the HTTP request:
   "method" = "GET": The type of HTTP request.
   "uri" = "https://api.example.com/data": The endpoint to which the request is sent.

"runAfter" = {}
Specifies conditions under which this action will run, which is empty in this case

"triggers" = { ... }
This block defines what starts the Logic App. Here it is set to manual.

"manual" = { ... }
Names the trigger "manual".

"inputs" = {}
Specifies any inputs required to start the Logic App.

"kind" = "Http": Specifies that this is an HTTP trigger.

"type" = "Request": Indicates the type of trigger.
