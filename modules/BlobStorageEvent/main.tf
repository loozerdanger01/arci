
resource "azurerm_application_insights" "blob_storage_function_insight" {
  name                = "${var.resource_prefix}-blob-storage-event-function-app"
  location            = var.backend_resource_location
  resource_group_name = var.backend_resource_group_name
  application_type    = "java"
  retention_in_days   = 30
}

resource "azurerm_service_plan" "blob_storage_event_function_app_service_plan" {
  name                     = "${var.resource_prefix}-blob-storage-event-function-app-service-plan"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}


resource "azurerm_linux_function_app" "blob_storage_event_function_app" {
  name                     = "${var.resource_prefix}-blob-storage-event-function-app"
  resource_group_name      = var.backend_resource_group_name
  location                 = var.backend_resource_location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id            = azurerm_service_plan.blob_storage_event_function_app_service_plan.id
  site_config {
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      docker {
        registry_url = "https://${var.container_registry_url}"
        image_name =  var.blob_storage_event_docker_image_name
        image_tag = var.blob_storage_event_docker_image_tag
        registry_username = var.container_registry_username
        registry_password = var.container_registry_password
      }
    }
  }

   app_settings = {
     APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.blob_storage_function_insight.instrumentation_key
     APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.blob_storage_function_insight.connection_string
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

  depends_on = [ azurerm_service_plan.blob_storage_event_function_app_service_plan ]
}


data "azurerm_linux_function_app" "blob_storage_event_function_app_data" {
  name = azurerm_linux_function_app.blob_storage_event_function_app.name
  resource_group_name = var.backend_resource_group_name

  depends_on = [ azurerm_linux_function_app.blob_storage_event_function_app ]
}


resource "azurerm_role_assignment" "blob_storage_event_function_app_acr_image_pull_access" {
  scope                = var.acr_container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_function_app.blob_storage_event_function_app_data.identity.0.principal_id
  depends_on = [ data.azurerm_linux_function_app.blob_storage_event_function_app_data ]
}


resource "azurerm_role_assignment" "blob_storage_event_function_app_storage_account_access" {
  scope                = var.primary_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_linux_function_app.blob_storage_event_function_app_data.identity.0.principal_id
}


resource "azurerm_eventgrid_system_topic" "blob_storage" {
  name                   = "blob-storage-system-topic"
  location               = var.backend_resource_location
  resource_group_name    = var.portal_resource_group
  source_arm_resource_id = var.primary_storage_account_id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}


resource "azurerm_eventgrid_system_topic_event_subscription" "blob_storage_event" {
  name                = "blob-storage-event-subscription"
  system_topic        = azurerm_eventgrid_system_topic.blob_storage.name
  resource_group_name = var.portal_resource_group

  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.blob_storage_event_function_app.id}/functions/${var.blob_storage_trigger_function_name}"
  }

  included_event_types = ["Microsoft.Storage.BlobCreated"]

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${var.firmware_container_name}/"
  }

  depends_on = [ azurerm_linux_function_app.blob_storage_event_function_app ]
}

resource "azurerm_monitor_action_group" "blob_storage_event_function_app_server_failure_action" {
  name                = "${var.resource_prefix}-blob-storage-event-function-app-server-failure-action"
  resource_group_name = var.backend_resource_group_name
  short_name          = "blobevnt-err"

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


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "blob_storage_event_server_failure_rule" {
  name                = "${var.resource_prefix}-blob-storage-event-server-failure-alert"
  resource_group_name = var.backend_resource_group_name
  scopes              = [azurerm_application_insights.blob_storage_function_insight.id]
  location            = var.backend_resource_location
  criteria {
    query                   = <<-QUERY
    traces
      | project
          timestamp, message, cloud_RoleName, operation_Name
      | where cloud_RoleName =~ '${azurerm_linux_function_app.blob_storage_event_function_app.name}'
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
    action_groups = [azurerm_monitor_action_group.blob_storage_event_function_app_server_failure_action.id]
  }
}
