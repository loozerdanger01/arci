output "mobile_api_id" {
  value = azurerm_api_management_api.mobile_api.id
}

output "mobile_api_base_url" {
  value = "https://${azurerm_api_management_api.mobile_api.name}.azure-api.net/${azurerm_api_management_api.mobile_api.path}"
}


output "mobile_api_outbound_ip_list" {
  value = azurerm_linux_function_app.mobile_api_function_app.possible_outbound_ip_address_list
}
