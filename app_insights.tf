#Application Insights helps you monitor your live applications. It's part of Azure Monitor but specifically for application performance monitoring.

resource "azurerm_application_insights" "example" {
  name                = "example-app-insights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"                                         # The type of application you're monitoring (e.g., web app)

  # Link Application Insights with the Log Analytics Workspace
  workspace_id = azurerm_log_analytics_workspace.example.id
}



