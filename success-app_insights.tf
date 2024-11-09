provider "azurerm" {
  features {}
subscription_id   =    "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Resource group for SQL Server and Database
variable "resource_group_name" {
  default = "RG1"
}

data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Define Log Analytics Workspace (required for newer regions in Azure)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-law"
  location            = data.azurerm_resource_group.existing.location  # Use location from the data block
  resource_group_name = data.azurerm_resource_group.existing.name      # Use existing resource group name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Define Application Insights
resource "azurerm_application_insights" "example" {
  name                = "example-appinsights"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  application_type    = "web"  # Options include web, other, java, etc.

  # Set to Log Analytics Workspace created above
  workspace_id = azurerm_log_analytics_workspace.example.id

  # Sampling percentage: reduce telemetry data volume to save costs
  sampling_percentage = 20

  # Retention (for basic logs in Application Insights)
  retention_in_days = 30

  # Daily data cap in GB (set to 0 for no limit)
  daily_data_cap_in_gb = 5

  # Data cap notifications
  daily_data_cap_notifications_disabled = false

  # Force customer-managed encryption if required

  # Tags for resource management
  tags = {
       Environment = "Development"
    Project     = "ExampleProject"
  }
}

# Optional: Define Diagnostic Settings for Application Insights
# Sends logs to a storage account, Log Analytics, or an Event Hub
resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "appinsights-diagnostics"
  target_resource_id         = azurerm_application_insights.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log {
    category = ["Request", "Availability", "PerformanceCounters", "Event"]
    enabled  = true
    retention_policy {
      enabled = false
    }
  }

  metric {
    category = ["AllMetrics"]
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
}

output "application_insights_instrumentation_key" {
  value = azurerm_application_insights.example.instrumentation_key
}

output "application_insights_app_id" {
  value = azurerm_application_insights.example.app_id
}                                 
