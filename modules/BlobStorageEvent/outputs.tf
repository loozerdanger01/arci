output "blob_storage_notfication_outbound_ip_list" {
  value = azurerm_linux_function_app.blob_storage_event_function_app.possible_outbound_ip_address_list
}
