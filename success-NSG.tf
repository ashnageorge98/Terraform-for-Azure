provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}

# Variables for general settings
variable "location" {
  default = "eastus"  # Change to your preferred Azure region
}

variable "resource_group_name" {
  default = "myNewResourceGroup"  # Change this if desired
}

# Map variable for specific NSG configurations
variable "nsg_configs" {
  description = "Map of NSG configurations with specific security rules"
  type = map(object({
    location        = string
    security_rules  = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))

  default = {
    nsg1 = {
      location = "eastus"
      security_rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    nsg2 = {
      location = "eastus"
      security_rules = [
        {
          name                       = "AllowHTTP"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    nsg3 = {
      location = "eastus"
      security_rules = [
        {
          name                       = "AllowHTTPS"
          priority                   = 102
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

# Network Security Groups creation using for_each with specific rules per NSG
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsg_configs
  name                = each.key
  location            = each.value.location
  resource_group_name = var.resource_group_name

  # Adding security rules based on each NSG's configuration
  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Output for NSG IDs
output "nsg_ids" {
  description = "IDs of created NSGs"
  value       = { for nsg in azurerm_network_security_group.nsg : nsg.name => nsg.id }
}
