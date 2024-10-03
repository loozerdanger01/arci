output "scheduler_outbound_ip_list" {
  value = azurerm_linux_function_app.scheduler_function_app.possible_outbound_ip_address_list
}
