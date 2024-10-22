# Storage account definition
resource "azurerm_storage_account" "storage" {
  name                     = "examplestoracc123"  # Must be globally unique
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"  # Options: LRS, GRS, RAGRS, ZRS, etc.
  enable_https_traffic_only = true
}

# Azure File Share definition
resource "azurerm_storage_share" "fileshare" {
  name                 = "examplefileshare"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 5120  # Size in GB
}
