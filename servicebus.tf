# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Define a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "example-resource-group"
  location = "East US"

  tags = {
    environment = "Production"
    owner       = "example-owner"
  }
}

# Create an Azure Service Bus Namespace
resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "example-sb-namespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"  # Options: Basic, Standard, Premium

  tags = {
    environment = "Production"
    owner       = "example-owner"
  }
}

# Create a Service Bus Queue
resource "azurerm_servicebus_queue" "sb_queue" {
  name                = "example-queue"
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_servicebus_namespace.sb_namespace.name

  enable_dead_lettering_on_message_expiration = true
  enable_partitioning                          = false
  lock_duration                                = "PT5M"  # Format: ISO 8601 duration
  max_delivery_count                           = 10
  max_size_in_megabytes                        = 1024  # 1 GB
  requires_duplicate_detection                 = true
  requires_session                             = false
  default_message_ttl                          = "PT1H"  # 1 hour

  tags = {
    environment = "Production"
    owner       = "example-owner"
  }
}

# Create a Service Bus Topic
resource "azurerm_servicebus_topic" "sb_topic" {
  name                = "example-topic"
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_servicebus_namespace.sb_namespace.name

  enable_partitioning              = true
  enable_duplicate_detection       = true
  duplicate_detection_time_to_live = "PT10M"  # 10 minutes

  tags = {
    environment = "Production"
    owner       = "example-owner"
  }
}

# Create a Service Bus Subscription for the Topic
resource "azurerm_servicebus_subscription" "sb_subscription" {
  name                = "example-subscription"
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_servicebus_namespace.sb_namespace.name
  topic_name          = azurerm_servicebus_topic.sb_topic.name

  lock_duration           = "PT5M"  # 5 minutes
  max_delivery_count      = 10
  enable_dead_lettering_on_message_expiration = true

  tags = {
    environment = "Production"
    owner       = "example-owner"
  }
}
