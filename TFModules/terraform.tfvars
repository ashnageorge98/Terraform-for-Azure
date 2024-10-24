# General Configuration
resource_group_name = "myResourceGroup"
location            = "East US"

# VNet Configuration
vnet_name           = "myVNet"
address_space       = ["10.0.0.0/16"]

# Subnet Configuration
subnet_name         = "mySubnet"
subnet_address_prefix = "10.0.1.0/24"

# VM Configuration
vm_name             = "myVM"
vm_size             = "Standard_DS1_v2"
admin_username      = "adminuser"
ssh_key             = file("~/.ssh/id_rsa.pub")

# Storage Account Configuration
storage_account_name   = "mystorageacct"
account_tier           = "Standard"
replication_type       = "LRS"
container_name         = "mycontainer"
container_access_type  = "private"

# SQL Server and Database Configuration
sql_server_name        = "mySqlServer"
database_name          = "mySqlDatabase"
admin_login            = "sqladmin"
admin_password         = "SuperSecretPassword123!"  # Store this securely in real environments
service_objective      = "S1"  # Example service level for SQL Database (e.g., S0, S1, P1)
