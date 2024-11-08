
provider "azurerm" {
  features {}
subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Use existing resource group to create Recovery Services Vault
data "azurerm_resource_group" "existing" {
  name = "RG1"
}

# Define the Recovery Services Vault in existing resource group
resource "azurerm_recovery_services_vault" "example" {
  name                = "example-recovery-vault"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  sku                  = "Standard" # You can use 'Basic' or 'Standard'

  # Optional: Define the tags for organizational purposes
  tags = {
    environment = "production"
    department  = "IT"
  }
}

# Optional: Configure backup policy for VMs within the Recovery Services Vault
resource "azurerm_backup_policy_vm" "example" {
  recovery_vault_name        = azurerm_recovery_services_vault.example.name
  name                       = "example-backup-policy"
  resource_group_name        = data.azurerm_resource_group.existing.name

  # Backup schedule configuration
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  # Retention configuration
  retention_daily {
    count = 30
    }
  }

# Optional: Define a backup protected VM in Recovery Services Vault
resource "azurerm_backup_protected_vm" "example" {
  resource_group_name        = data.azurerm_resource_group.existing.name
  recovery_vault_name        = azurerm_recovery_services_vault.example.name
  source_vm_id               = "/subscriptions/81b0b41e-5edd-4af2-86ea-1b1457a4374c/resourceGroups/RG1/providers/Microsoft.Compute/virtualMachines/exampleVM-1"
  backup_policy_id           = azurerm_backup_policy_vm.example.id
}
