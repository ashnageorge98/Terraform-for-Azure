
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name  = "tfstatestorage"
    container_name        = "tfstate-container"
    key                   = "terraform.tfstate"
    use_azure_storage_locks = true                 # Enable locking
  }
}
- When use_azure_storage_locks is set to true, Terraform will use Azure Blob leases to ensure that only one instance of Terraform can modify the state file at a time.
If a second command attempts to acquire the lease, it will fail with a locking error until the first command is complete.

Terraform State File: This file stores the state of your infrastructure managed by Terraform. 
It acts as a source of truth for your resources and enables Terraform to determine what changes need to be applied to achieve the desired state.

Remote State Storage: In real-world scenarios, especially when working in teams, it is essential to store the state file remotely (e.g., in Azure Storage). 
This prevents conflicts and allows multiple users to work with the same infrastructure.

State File Locking: To avoid concurrent operations that could corrupt the state, Terraform provides state file locking. 
This is typically done using a backend that supports locking, such as Azure Blob Storage.

--
Define location , vnet and subnet as well
create var.tf, storage account and res group, and output.tf
create azure-pipeline.yml
resource "azurerm_virtual_network" "main" {
  name                = "tfstate-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "tfstate-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

State File Locking
When using the azurerm backend, Terraform automatically locks the state file when a command is running (like apply). 
This prevents other Terraform processes from interfering. The locking mechanism uses Azure Blob Storage
