output "web_api_id" {
  value = azurerm_api_management_api.web_api.id
}

output "web_api_base_url" {
  value = "https://${azurerm_api_management_api.web_api.name}.azure-api.net/${azurerm_api_management_api.web_api.path}"
}


output "web_api_outbound_ip_list" {
  value = azurerm_linux_function_app.web_api_function_app.possible_outbound_ip_address_list
}