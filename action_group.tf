resource "azurerm_monitor_action_group" "example" {
  name                = "example-action-group"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "exAlertGrp"  # Short name for the action group

  email_receiver {
    name          = "example-email-receiver"
    email_address = "your-email@example.com"  # Email address to notify
  }
}
