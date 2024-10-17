#Azure Monitoring Setup (via Azure Monitor)
#Here’s how you can create an Azure Monitor setup to log metrics and send them to a Log Analytics Workspace.

#Monitoring and Log Analytics Terraform Script (monitoring.tf):

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "my-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Azure Monitor Diagnostic Setting for App Service
resource "azurerm_monitor_diagnostic_setting" "appservice_diag" {
  name               = "my-appservice-monitor"
  target_resource_id = azurerm_app_service.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  logs {
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }

  metrics {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
}

# Send Activity Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "activity_log_diag" {
  name               = "activity-log-to-log-analytics"
  target_resource_id = "/subscriptions/${data.azurerm_client_config.example.subscription_id}/providers/microsoft.insights/components"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  logs {
    category = "Administrative"
    enabled  = true
  }

  logs {
    category = "Security"
    enabled  = true
  }

  logs {
    category = "ServiceHealth"
    enabled  = true
  }
}
