
output "iot_messenger_outbound_ip_list" {
  value = azurerm_linux_function_app.iot_messenger_function_app.possible_outbound_ip_address_list
}
