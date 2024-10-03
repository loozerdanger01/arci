resource "azurerm_resource_group" "backend_resources" {
  name     = "${var.resource_prefix}-backend-resource-group"
  location = var.resource_location
}

data "azurerm_storage_account" "primary_storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.portal_resource_group
}

resource "azurerm_storage_container" "assets_container" {
  name                  = "${var.resource_prefix}-assets-container"
  storage_account_name  = data.azurerm_storage_account.primary_storage_account.name
  container_access_type = "container"
}

resource "azurerm_storage_container" "firmwares_container" {
  name                  = "${var.resource_prefix}-firmwares-container"
  storage_account_name  = data.azurerm_storage_account.primary_storage_account.name
  container_access_type = "private"
}


resource "azurerm_storage_container" "certificates_container" {
  name                  = "${var.resource_prefix}-certificates-container"
  storage_account_name  = data.azurerm_storage_account.primary_storage_account.name
  container_access_type = "private"
}


resource "azurerm_api_management" "api_management_service" {
  name                = "${var.resource_prefix}-api-management"
  location            = azurerm_resource_group.backend_resources.location
  resource_group_name = azurerm_resource_group.backend_resources.name
  publisher_name      = var.resource_prefix
  publisher_email     = var.company_email

  sku_name = "Consumption_0"

  protocols {
    enable_http2 = true
  }

  security {
    enable_backend_ssl30 = true
    enable_backend_tls10 = true
    enable_backend_tls11 = true
  }

  depends_on = [ azurerm_resource_group.backend_resources, data.azurerm_storage_account.primary_storage_account ]
}


data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.portal_resource_group
}
