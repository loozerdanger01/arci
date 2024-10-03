
output "google_home_handler_out_bound_list" {
  value = azurerm_linux_function_app.google_home_handler_function_app.possible_outbound_ip_address_list
}

output "alexa_home_handler_outbound_list" {
  value = azurerm_linux_function_app.alexa_handler_function_app.outbound_ip_address_list
}

output "smart_assistant_handler_function_name" {
  value = azurerm_linux_function_app.smart_assistant_manager_function_app.name
}