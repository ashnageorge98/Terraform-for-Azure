provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "East US"
}

# Storage Account for Event Subscription (Optional, for Demo Purposes)
resource "azurerm_storage_account" "example" {
  name                     = "examplestoragetf123"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Event Grid System Topic
resource "azurerm_eventgrid_system_topic" "example" {
  name                = "example-system-topic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  source_arm_resource_id = azurerm_storage_account.example.id

  input_schema = "EventGridSchema" # Other options: "CustomEventSchema", "CloudEventSchemaV1_0"

  tags = {
    Environment = "Development"
    Owner       = "TerraformUser"
  }
}

# Event Subscription for System Topic
resource "azurerm_eventgrid_event_subscription" "example" {
  name  = "example-subscription"
  scope = azurerm_eventgrid_system_topic.example.id

  webhook_endpoint {
    url = "https://example-webhook.com/eventhandler"
  }

  # Optional: Event Delivery with Retry Policy
  retry_policy {
    max_delivery_attempts = 5
    event_time_to_live_in_minutes = 1440 # 1 day
  }

  # Optional: Advanced Filtering Example
  advanced_filter {
    key    = "Data.Category"
    operator_type = "StringIn"
    values = ["Critical", "Warning"]
  }

  # Enable Dead Lettering (Optional)
  storage_blob_dead_letter_destination {
    storage_account_id = azurerm_storage_account.example.id
    blob_container_name = "deadletter-container"
  }
}

# Storage Container for Dead Lettering
resource "azurerm_storage_container" "deadletter" {
  name                  = "deadletter-container"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}
