resource "azurerm_public_ip" "public_ip" {
  name                = "examplePublicIP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "example_lb" {
  name                = "exampleLoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontendConfig"
    subnet_id            = azurerm_subnet.example_subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "example_pool" {
  loadbalancer_id = azurerm_lb.example_lb.id
  name            = "exampleBackendPool"
}

resource "azurerm_lb_probe" "example_probe" {
  loadbalancer_id = azurerm_lb.example_lb.id
  name            = "exampleHealthProbe"
  protocol        = "Tcp"
  port            = 80
  interval_in_seconds = 5
  number_of_probes     = 2
}

resource "azurerm_lb_rule" "example_rule" {
  loadbalancer_id            = azurerm_lb.example_lb.id
  name                       = "exampleLoadBalancerRule"
  protocol                   = "Tcp"
  frontend_port              = 80
  backend_port               = 80
  frontend_ip_configuration  = azurerm_lb.example_lb.frontend_ip_configuration[0].id
  backend_address_pool_id    = azurerm_lb_backend_address_pool.example_pool.id
  probe_id                   = azurerm_lb_probe.example_probe.id
  enable_floating_ip         = false
  idle_timeout_in_minutes    = 4
}

resource "azurerm_network_security_group" "example_nsg" {
  name                = "exampleNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowLoadBalancer"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}
