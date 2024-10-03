output "server_private_ip" {
  value = azurerm_linux_virtual_machine.timescale_instance.private_ip_address
}

output "server_public_ip" {
  value = azurerm_linux_virtual_machine.timescale_instance.public_ip_address
}

output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.timescale_instance.id
}