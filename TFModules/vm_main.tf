resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_key
  }

  network_interface_ids = [var.network_interface_id]
  os_disk {
    caching              = "ReadWrite"
    create_option        = "FromImage"
    managed_disk_type    = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}
