#Managed disk
resource "azurerm_managed_disk" "example" {
  name                 = "mymanageddisk"                       # Name of the managed disk
  resource_group_name  = "myresourcegroup"                     # Resource group name
  location             = "East US"                             # Location of the disk
  storage_account_type = "Standard_LRS"                        # Type of storage: Standard or Premium LRS
  create_option        = "Empty"                               # Option to create an empty disk (others: "FromImage", "Import")
  disk_size_gb         = 128                                   # Size of the disk in GB
}
  # Optional: Tags
  tags = {
    environment = "testing"
  }

#Unmanaged disk
resource "azurerm_managed_disk" "example" {
  name                 = "mymanageddisk"                       # Name of the managed disk
  resource_group_name  = "myresourcegroup"                     # Resource group name
  location             = "East US"                             # Location of the disk
  storage_account_type = "Standard_LRS"                        # Type of storage: Standard or Premium LRS
  create_option        = "Empty"                               # Option to create an empty disk (others: "FromImage", "Import")
  disk_size_gb         = 128                                   # Size of the disk in GB
}
