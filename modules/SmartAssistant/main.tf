
resource "azurerm_service_plan" "smart_assitants_manager_function_app_service_plan" {
  name                     = "${var.resource_prefix}-smart-assistants-manager-function-app-service-plan"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}

resource "azurerm_service_plan" "alexa_handler_function_app_service_plan" {
  name                     = "${var.resource_prefix}-alexa-handler-function-app-service-plan"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}

resource "azurerm_service_plan" "google_home_handler_function_app_service_plan" {
  name                     = "${var.resource_prefix}-google-home-handler-function-app-service-plan"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}

resource "azurerm_service_plan" "smart_assitants_function_app_service_plan" {
  name                     = "${var.resource_prefix}-smart-assistants-function-app-service-plan"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}

data "azurerm_application_insights" "smart_assistant_manager_function_insight" {
  name                = "${var.resource_prefix}-smart-assistant-manager-function-app"
  resource_group_name = var.backend_resource_group_name
}

resource "azurerm_linux_function_app" "smart_assistant_manager_function_app" {
  name                     = "${var.resource_prefix}-smart-assistant-manager-function-app"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.smart_assitants_manager_function_app_service_plan.id

  site_config {
    always_on = true
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      docker {
        registry_url = "https://${var.container_registry_url}"
        image_name =  var.smart_assistant_manager_docker_image_name
        image_tag = var.smart_assistant_manager_docker_image_tag
        registry_username = var.container_registry_username
        registry_password = var.container_registry_password
      }
    }
  }

   app_settings = {
     APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.smart_assistant_manager_function_insight.instrumentation_key
     APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.smart_assistant_manager_function_insight.connection_string
     WEBSITES_ENABLE_APP_SERVICE_STORAGE  = false
     CERTIFICATE_CONTAINER_NAME = var.certificate_container_name
     FIRMWARE_CONTAINER_NAME = var.firmware_container_name
     GOOGLE_HOME_HANDLER = "https://${azurerm_linux_function_app.google_home_handler_function_app.name}.azurewebsites.net/api"
     ALEXA_HANDLER = "https://${azurerm_linux_function_app.alexa_handler_function_app.name}.azurewebsites.net/api"
     EXTERNAL_SERVICE_BASE_URL = var.external_service_base_url
     AZURE_KEY_VAULT_URI = "https://${var.key_vault_name}.vault.azure.net/"
     STORAGE_ACCOUNT_ENDPOINT = "https://${var.storage_account_name}.blob.core.windows.net"
     DeviceManufacturer = var.company_name
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    developer   = "IoTfy"
    environment = var.environment
  }

  depends_on = [ azurerm_service_plan.smart_assitants_function_app_service_plan ]
}

data "azurerm_linux_function_app" "smart_assistant_manager_function_app_data" {
  name = azurerm_linux_function_app.smart_assistant_manager_function_app.name
  resource_group_name = var.backend_resource_group_name

  depends_on = [ azurerm_linux_function_app.smart_assistant_manager_function_app ]
}


resource "azurerm_role_assignment" "smart_assistant_manager_function_app_acr_image_pull_access" {
  scope                = var.acr_container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_function_app.smart_assistant_manager_function_app_data.identity.0.principal_id
  depends_on = [ data.azurerm_linux_function_app.smart_assistant_manager_function_app_data ]
}


# Grant permission to web api function app for accessing storage
resource "azurerm_role_assignment" "smart_assistant_manager_function_app_storage_account_access" {
  scope                = var.primary_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_linux_function_app.smart_assistant_manager_function_app_data.identity.0.principal_id
}

# google_home_handler
data "azurerm_application_insights" "google_home_handler_function_insight" {
  name                = "${var.resource_prefix}-google-home-handler-function-app"
  resource_group_name = var.backend_resource_group_name
}

resource "azurerm_linux_function_app" "google_home_handler_function_app" {
  name                     = "${var.resource_prefix}-google-home-handler-function-app"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.google_home_handler_function_app_service_plan.id

  site_config {
    always_on = true
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      docker {
        registry_url = "https://${var.container_registry_url}"
        image_name =  var.google_home_handler_docker_image_name
        image_tag = var.google_home_handler_docker_image_tag
        registry_username = var.container_registry_username
        registry_password = var.container_registry_password
      }
    }
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.google_home_handler_function_insight.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.google_home_handler_function_insight.connection_string
    WEBSITES_ENABLE_APP_SERVICE_STORAGE  = false
    CERTIFICATE_CONTAINER_NAME = var.certificate_container_name
    FIRMWARE_CONTAINER_NAME = var.firmware_container_name
    EXTERNAL_SERVICE_BASE_URL = var.external_service_base_url
    AZURE_KEY_VAULT_URI = "https://${var.key_vault_name}.vault.azure.net/"
    STORAGE_ACCOUNT_ENDPOINT = "https://${var.storage_account_name}.blob.core.windows.net"
    DeviceManufacturer = var.company_name
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    developer   = "IoTfy"
    environment = var.environment
  }

  depends_on = [ azurerm_service_plan.google_home_handler_function_app_service_plan ]
}

data "azurerm_linux_function_app" "google_home_handler_function_app_data" {
  name = azurerm_linux_function_app.google_home_handler_function_app.name
  resource_group_name = var.backend_resource_group_name

  depends_on = [ azurerm_linux_function_app.google_home_handler_function_app ]
}


resource "azurerm_role_assignment" "google_home_handler_function_app_acr_image_pull_access" {
  scope                = var.acr_container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_function_app.google_home_handler_function_app_data.identity.0.principal_id
  depends_on = [ data.azurerm_linux_function_app.google_home_handler_function_app_data ]
}


# Grant permission to google home function app for accessing storage
resource "azurerm_role_assignment" "google_home_handler_function_app_storage_account_access" {
  scope                = var.primary_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_linux_function_app.google_home_handler_function_app_data.identity.0.principal_id
}


# Alexa-handler

data "azurerm_application_insights" "alexa_handler_function_insight" {
  name                = "${var.resource_prefix}-alexa-handler-function-app"
  resource_group_name = var.backend_resource_group_name
}

resource "azurerm_linux_function_app" "alexa_handler_function_app" {
  name                     = "${var.resource_prefix}-alexa-handler-function-app"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.alexa_handler_function_app_service_plan.id

  site_config {
    always_on = true
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      docker {
        registry_url = "https://${var.container_registry_url}"
        image_name =  var.alexa_home_handler_docker_image_name
        image_tag = var.alexa_home_handler_docker_image_tag
        registry_username = var.container_registry_username
        registry_password = var.container_registry_password
      }
    }
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.alexa_handler_function_insight.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.alexa_handler_function_insight.connection_string
    WEBSITES_ENABLE_APP_SERVICE_STORAGE  = false
    CERTIFICATE_CONTAINER_NAME = var.certificate_container_name
    FIRMWARE_CONTAINER_NAME = var.firmware_container_name
    EXTERNAL_SERVICE_BASE_URL = var.external_service_base_url
    AZURE_KEY_VAULT_URI = "https://${var.key_vault_name}.vault.azure.net/"
    STORAGE_ACCOUNT_ENDPOINT = "https://${var.storage_account_name}.blob.core.windows.net"
    DeviceManufacturer = var.company_name
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    developer   = "IoTfy"
    environment = var.environment
  }

  depends_on = [ azurerm_service_plan.alexa_handler_function_app_service_plan ]
}

data "azurerm_linux_function_app" "alexa_handler_function_app_data" {
  name = azurerm_linux_function_app.alexa_handler_function_app.name
  resource_group_name = var.backend_resource_group_name

  depends_on = [ azurerm_linux_function_app.alexa_handler_function_app ]
}


resource "azurerm_role_assignment" "alexa_handler_function_app_acr_image_pull_access" {
  scope                = var.acr_container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_function_app.alexa_handler_function_app_data.identity.0.principal_id
  depends_on = [ data.azurerm_linux_function_app.alexa_handler_function_app_data ]
}


# Grant permission to web api function app for accessing storage
resource "azurerm_role_assignment" "alexa_home_handler_function_app_storage_account_access" {
  scope                = var.primary_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_linux_function_app.alexa_handler_function_app_data.identity.0.principal_id
}
