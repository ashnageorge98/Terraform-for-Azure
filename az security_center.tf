# also called microsoft defender for cloud

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "East US"
}

resource "azurerm_security_center_setting" "example" {
  name                           = "default"
  resource_group_name            = azurerm_resource_group.example.name
  subscription_id                = "<YOUR_SUBSCRIPTION_ID>"
  automation_enabled             = true
  daily_email_notifications      = true
  notifications_enabled          = true
  pricing_tier                   = "Standard"
}

Notes:
automation_enabled = true: This setting enables automation features in Azure Security Center, such as automatic threat detection.
daily_email_notifications = true: When set to true, this option will send you daily email notifications about the security status of your resources.
notifications_enabled = true: This enables notifications for security alerts, meaning you will receive alerts if any issues are detected.
pricing_tier = "Standard": This specifies the pricing tier for Azure Security Center. The "Standard" tier includes advanced features compared to the "Free" tier.
