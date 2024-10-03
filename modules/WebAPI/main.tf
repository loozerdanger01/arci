
resource "azurerm_service_plan" "web_function_app_service_plan" {
  name                     = "${var.resource_prefix}-web-function-app-service-plan"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}


data "azurerm_application_insights" "web_api_function_insight" {
  name                = "${var.resource_prefix}-web-api-function-app"
  resource_group_name = var.backend_resource_group_name
}


resource "azurerm_linux_function_app" "web_api_function_app" {
  name                     = "${var.resource_prefix}-web-api-function-app"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.web_function_app_service_plan.id

  site_config {
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      docker {
        registry_url = "https://${var.container_registry_url}"
        image_name =  var.web_api_docker_image_name
        image_tag = var.web_api_docker_image_tag
        registry_username = var.container_registry_username
        registry_password = var.container_registry_password
      }
    }
  }

   app_settings = {
     APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.web_api_function_insight.instrumentation_key
     APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.web_api_function_insight.connection_string
     WEBSITES_ENABLE_APP_SERVICE_STORAGE  = false
     CERTIFICATE_CONTAINER_NAME = var.certificate_container_name
     FIRMWARE_CONTAINER_NAME = var.firmware_container_name
     EXTERNAL_SERVICE_BASE_URL = var.external_service_base_url
     AZURE_KEY_VAULT_URI = "https://${var.key_vault_name}.vault.azure.net/"
     STORAGE_ACCOUNT_ENDPOINT = "https://${var.storage_account_name}.blob.core.windows.net"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    developer   = "IoTfy"
    environment = var.environment
  }

  depends_on = [ azurerm_service_plan.web_function_app_service_plan ]
}

data "azurerm_linux_function_app" "web_api_function_app_data" {
  name = azurerm_linux_function_app.web_api_function_app.name
  resource_group_name = var.backend_resource_group_name

  depends_on = [ azurerm_linux_function_app.web_api_function_app ]
}


resource "azurerm_role_assignment" "web_api_function_app_acr_image_pull_access" {
  scope                = var.acr_container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_function_app.web_api_function_app_data.identity.0.principal_id
  depends_on = [ data.azurerm_linux_function_app.web_api_function_app_data ]
}


# Grant permission to web api function app for accessing storage
resource "azurerm_role_assignment" "web_api_function_app_storage_account_access" {
  scope                = var.primary_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_linux_function_app.web_api_function_app_data.identity.0.principal_id
}

data "azurerm_function_app_host_keys" "web_api_function_host_keys" {
  name                = azurerm_linux_function_app.web_api_function_app.name
  resource_group_name = var.backend_resource_group_name
}


resource "azurerm_api_management_backend" "web_api_backend" {
  name                = "${var.resource_prefix}-web-function-app-backend"
  resource_group_name = var.backend_resource_group_name
  api_management_name = var.api_management_name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.web_api_function_app.name}.azurewebsites.net/api/"
  credentials {
    header = {
      "x-functions-key" = data.azurerm_function_app_host_keys.web_api_function_host_keys.default_function_key
    }
  }

  depends_on = [
    azurerm_linux_function_app.web_api_function_app,
    data.azurerm_function_app_host_keys.web_api_function_host_keys
  ]
}


resource "azurerm_api_management_api" "web_api" {
  name                = "${var.resource_prefix}-web-api"
  resource_group_name = var.backend_resource_group_name
  api_management_name = var.api_management_name
  revision            = "1"
  display_name        = "${var.resource_prefix}-web-api"
  api_type            = "http"
  path                = "lnt-web-api"
  protocols           = ["https"]
  subscription_required = false

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/docs.yml")
  }
}

resource "azurerm_api_management_api_policy" "web_api_backend_policy" {
  api_name            = azurerm_api_management_api.web_api.name
  api_management_name = var.api_management_name
  resource_group_name = var.backend_resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <base/>
    <set-backend-service backend-id="${azurerm_api_management_backend.web_api_backend.name}" />
  </inbound>
</policies>
XML
}


resource "azurerm_monitor_action_group" "web_api_server_failure_action" {
  name                = "${var.resource_prefix}-web-api-server-failure-action"
  resource_group_name = var.backend_resource_group_name
  short_name          = "web-api-err"

  email_receiver {
    name                    = "sendtodevops"
    email_address           = var.devops_email
    use_common_alert_schema = true
  }

  tags = {
    developer = "IoTfy"
    environment = var.environment
  }
}


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "web_api_server_failure_rule" {
  name                = "${var.resource_prefix}-web-api-server-failure-alert"
  resource_group_name = var.backend_resource_group_name
  scopes              = [data.azurerm_application_insights.web_api_function_insight.id]
  location            = var.backend_resource_location
  criteria {
    query                   = <<-QUERY
    traces
      | project
          timestamp, message, cloud_RoleName, operation_Name
      | where cloud_RoleName =~ '${azurerm_linux_function_app.web_api_function_app.name}'
      | where message has "Internal Exception"
      QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  severity = 1
  window_duration = "PT5M"
  evaluation_frequency = "PT5M"

   action {
    action_groups = [azurerm_monitor_action_group.web_api_server_failure_action.id]
  }
}
