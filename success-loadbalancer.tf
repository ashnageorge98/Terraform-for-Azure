
provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Virtual network
resource "azurerm_virtual_network" "example_vnet" {
  name                = "exampleVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example_subnet" {
  name                 = "exampleSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for the Load Balancer
resource "azurerm_public_ip" "example_pip" {
  name                = "examplePublicIP"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "example_lb" {
  name                = "exampleLB"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example_pip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "example_bap" {
  name                = "exampleBackendPool"
  loadbalancer_id     = azurerm_lb.example_lb.id
}

# Health Probe (HTTP)
resource "azurerm_lb_probe" "example_health_probe" {
  name                = "exampleHealthProbe"
  loadbalancer_id     = azurerm_lb.example_lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancing Rule
resource "azurerm_lb_rule" "example_lb_rule" {
  name                           = "HTTPRule"
  loadbalancer_id                = azurerm_lb.example_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.example_bap.id]
  probe_id                       = azurerm_lb_probe.example_health_probe.id
}

# NAT Rule for SSH access to backend VMs
resource "azurerm_lb_nat_rule" "example_nat_rule" {
  name                           = "SSHRule"
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Network Interface for VM
resource "azurerm_network_interface" "example_nic" {
  count               = 2
  name                = "exampleNIC-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"

    # Correctly assigning the NIC to the backend address pool
    load_balancer_backend_address_pool_ids = [
      azurerm_lb_backend_address_pool.example_bap.id
    ]
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "example_vm" {
  count               = 2
  name                = "exampleVM-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [azurerm_network_interface.example_nic[count.index].id]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}







#Notes:
Load Balancing Rule (Port 80): Distributes HTTP (web) traffic across multiple backend instances.
Setting backend_port = 80 means that the Load Balancer will forward incoming traffic on frontend_port = 80 to the backend VMs on port 80 as well.
Purpose: This rule is used for distributing incoming HTTP requests across multiple backend instances (e.g., web servers running on port 80).

NAT Rule (Port 22): Allows SSH access to individual backend VMs, usually for administrative purposes.
Setting backend_port = 22 means the Load Balancer will forward incoming SSH requests on frontend_port = 22 to backend VMs on port 22 as well.
Purpose: This rule allows external users to SSH into the backend VMs, typically for administrative access.
