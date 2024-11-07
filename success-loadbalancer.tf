provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Use existing resource group 'RG1'

# Virtual network
resource "azurerm_virtual_network" "example_vnet" {
  name                = "exampleVNet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"  # Set the location for the VNet
  resource_group_name = "RG1"
}

# Subnet
resource "azurerm_subnet" "example_subnet" {
  name                 = "exampleSubnet"
  resource_group_name  = "RG1"
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for the Load Balancer
resource "azurerm_public_ip" "example_pip" {
  name                = "examplePublicIP"
  location            = "East US"  # Set the location for the Public IP
  resource_group_name = "RG1"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "example_lb" {
  name                = "exampleLB"
  location            = "East US"  # Set the location for the Load Balancer
  resource_group_name = "RG1"
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
  resource_group_name            = "RG1"
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
  location            = "East US"  # Set location for NIC
  resource_group_name = "RG1"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"

    # Correctly assigning the NIC to the backend address pool
  }
}
# Virtual Machine
resource "azurerm_linux_virtual_machine" "example_vm" {
  count               = 2
  name                = "exampleVM-${count.index}"
  location            = "East US"  # Set location for VMs
  resource_group_name = "RG1"
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  disable_password_authentication = true

  # Add SSH key for authentication
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Path to your SSH public key file
  }

# if not using ssh key, then enter disable_password_authentication = false and delete admin_ssh_key block and run terraform validate

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

Notes:
backend_port = 80 (http)- http traffic coming to port 80 on frontend vm will be forwarded to backend vm in port 80 by the load balancer

backend_port = 22(ssh):
this is to ssh into vm usig port 22. here load balancer will forward traffic coming to vm in port 22 to backend vm in port 22. 
this is for admin activities for external users to login.
When SSH traffic arrives at the load balancer on port 22, it is forwarded to port 22 on the backend VMs. 
This allows you to SSH into your VMs for administrative tasks.
