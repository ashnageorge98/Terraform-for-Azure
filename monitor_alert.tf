resource "azurerm_monitor_metric_alert" "example" {
  name                = "example-metric-alert"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  scopes              = [azurerm_virtual_machine.example.id]  # Target resource for alert (e.g., a VM)
  description         = "Alert when CPU usage exceeds 80%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80  # Trigger alert if CPU exceeds 80%
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id  # Specify the action group for notifications
  }

  frequency  = "PT5M"  # Check every 5 minutes
  severity   = 3       # Severity level (1 = critical, 4 = informational)
  window_size = "PT5M"  # Monitoring time window of 5 minutes
}
