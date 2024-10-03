terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.90.0"
    }
  }
}

provider "tls" {
  proxy {
    from_env = true
  }
}

provider "azurerm" {
  skip_provider_registration = true 
  features {}
}

module "web_api_module" {
  source = "./modules/WebAPI"
  environment = var.environment
  resource_prefix = var.resource_prefix
  key_vault_id = data.azurerm_key_vault.key_vault.id

  acr_container_registry_id = azurerm_container_registry.container_registry.id
  container_registry_url = azurerm_container_registry.container_registry.login_server
  container_registry_username = azurerm_container_registry.container_registry.admin_username
  container_registry_password = azurerm_container_registry.container_registry.admin_password
  web_api_docker_image_name = var.web_api_docker_image_name
  web_api_docker_image_tag = var.web_api_docker_image_tag
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  storage_account_name = data.azurerm_storage_account.primary_storage_account.name
  primary_storage_account_id = data.azurerm_storage_account.primary_storage_account.id
  api_management_name = azurerm_api_management.api_management_service.name
  backend_resource_group_name = azurerm_resource_group.backend_resources.name
  backend_resource_location = azurerm_resource_group.backend_resources.location
  firmware_container_name = azurerm_storage_container.firmwares_container.name
  external_service_base_url = var.external_service_base_url
  key_vault_name = var.key_vault_name
  certificate_container_name = azurerm_storage_container.certificates_container.name
  devops_email = var.devops_email


  depends_on = [ 
    azurerm_api_management.api_management_service,
    data.azurerm_key_vault.key_vault,
    data.azurerm_storage_account.primary_storage_account,
    null_resource.web_api_docker_image_push
  ]
}


module "smart_assistant_module" {
  source = "./modules/SmartAssistant"
  environment = var.environment
  resource_prefix = var.resource_prefix
  key_vault_id = data.azurerm_key_vault.key_vault.id
  acr_container_registry_id = azurerm_container_registry.container_registry.id
  container_registry_url = azurerm_container_registry.container_registry.login_server
  container_registry_username = azurerm_container_registry.container_registry.admin_username
  container_registry_password = azurerm_container_registry.container_registry.admin_password
  smart_assistant_manager_docker_image_name = var.smart_assistant_manager_docker_image_name
  smart_assistant_manager_docker_image_tag = var.smart_assistant_manager_docker_image_tag
  google_home_handler_docker_image_name = var.google_home_handler_docker_image_name
  google_home_handler_docker_image_tag = var.google_home_handler_docker_image_tag
  alexa_home_handler_docker_image_name = var.alexa_home_handler_docker_image_name
  alexa_home_handler_docker_image_tag = var.alexa_home_handler_docker_image_tag
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  storage_account_name = data.azurerm_storage_account.primary_storage_account.name
  primary_storage_account_id = data.azurerm_storage_account.primary_storage_account.id
  backend_resource_group_name = azurerm_resource_group.backend_resources.name
  backend_resource_location = azurerm_resource_group.backend_resources.location
  firmware_container_name = azurerm_storage_container.firmwares_container.name
  external_service_base_url = var.external_service_base_url
  key_vault_name = var.key_vault_name
  certificate_container_name = azurerm_storage_container.certificates_container.name
  devops_email = var.devops_email
  company_name = var.company_name

  depends_on = [
    data.azurerm_key_vault.key_vault,
    data.azurerm_storage_account.primary_storage_account,
    null_resource.smart_assistant_manager_image_push,
    null_resource.alexa_handler_image_push,
    null_resource.google_home_handler_image_push
  ]
}



module "mobile_api_module" {
  source = "./modules/MobileAPI"
  environment = var.environment
  resource_prefix = var.resource_prefix
  key_vault_id = data.azurerm_key_vault.key_vault.id

  acr_container_registry_id = azurerm_container_registry.container_registry.id
  container_registry_url = azurerm_container_registry.container_registry.login_server
  container_registry_username = azurerm_container_registry.container_registry.admin_username
  container_registry_password = azurerm_container_registry.container_registry.admin_password
  mobile_api_docker_image_name = var.mobile_api_docker_image_name
  mobile_api_docker_image_tag = var.mobile_api_docker_image_tag
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  storage_account_name = data.azurerm_storage_account.primary_storage_account.name
  primary_storage_account_id = data.azurerm_storage_account.primary_storage_account.id
  api_management_name = azurerm_api_management.api_management_service.name
  backend_resource_group_name = azurerm_resource_group.backend_resources.name
  backend_resource_location = azurerm_resource_group.backend_resources.location
  firmware_container_name = azurerm_storage_container.firmwares_container.name
  external_service_base_url = var.external_service_base_url
  key_vault_name = var.key_vault_name
  certificate_container_name = azurerm_storage_container.certificates_container.name
  devops_email = var.devops_email
  smart_assistant_manager_handler_base_url = "https://${module.smart_assistant_module.smart_assistant_handler_function_name}.azurewebsites.net/api"

  depends_on = [
    azurerm_api_management.api_management_service,
    data.azurerm_key_vault.key_vault,
    data.azurerm_storage_account.primary_storage_account,
    null_resource.mobile_api_docker_image_push
  ]
}





module "iot_messenger_module" {
  source = "./modules/IoTMessenger"
  environment = var.environment
  resource_prefix = var.resource_prefix
  key_vault_id = data.azurerm_key_vault.key_vault.id

  acr_container_registry_id = azurerm_container_registry.container_registry.id
  container_registry_url = azurerm_container_registry.container_registry.login_server
  container_registry_username = azurerm_container_registry.container_registry.admin_username
  container_registry_password = azurerm_container_registry.container_registry.admin_password
  iot_messenger_docker_image_name = var.iot_messenger_docker_image_name
  iot_messenger_docker_image_tag = var.iot_messenger_docker_image_tag
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  storage_account_name = data.azurerm_storage_account.primary_storage_account.name
  primary_storage_account_id = data.azurerm_storage_account.primary_storage_account.id
  backend_resource_group_name = azurerm_resource_group.backend_resources.name
  backend_resource_location = azurerm_resource_group.backend_resources.location
  firmware_container_name = azurerm_storage_container.firmwares_container.name
  external_service_base_url = var.external_service_base_url
  key_vault_name = var.key_vault_name
  certificate_container_name = azurerm_storage_container.certificates_container.name
  devops_email = var.devops_email
  smart_assistant_manager_handler_base_url = "https://${module.smart_assistant_module.smart_assistant_handler_function_name}.azurewebsites.net/api"

  depends_on = [ 
    data.azurerm_key_vault.key_vault,
    data.azurerm_storage_account.primary_storage_account,
    null_resource.iot_messenger_docker_image_push
  ]
}


module "scheduler_module" {
  source = "./modules/Scheduler"
  environment = var.environment
  resource_prefix = var.resource_prefix
  key_vault_id = data.azurerm_key_vault.key_vault.id

  acr_container_registry_id = azurerm_container_registry.container_registry.id
  container_registry_url = azurerm_container_registry.container_registry.login_server
  container_registry_username = azurerm_container_registry.container_registry.admin_username
  container_registry_password = azurerm_container_registry.container_registry.admin_password
  scheduler_docker_image_name = var.scheduler_docker_image_name
  scheduler_docker_image_tag = var.scheduler_docker_image_tag
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  storage_account_name = data.azurerm_storage_account.primary_storage_account.name
  primary_storage_account_id = data.azurerm_storage_account.primary_storage_account.id
  backend_resource_group_name = azurerm_resource_group.backend_resources.name
  backend_resource_location = azurerm_resource_group.backend_resources.location
  firmware_container_name = azurerm_storage_container.firmwares_container.name
  external_service_base_url = var.external_service_base_url
  key_vault_name = var.key_vault_name
  certificate_container_name = azurerm_storage_container.certificates_container.name
  devops_email = var.devops_email


  depends_on = [ 
    data.azurerm_key_vault.key_vault,
    data.azurerm_storage_account.primary_storage_account,
    null_resource.scheduler_docker_image_push
  ]
}

module "blob_storage_event_module" {
  source = "./modules/BlobStorageEvent"
  environment = var.environment
  resource_prefix = var.resource_prefix

  acr_container_registry_id = azurerm_container_registry.container_registry.id
  container_registry_url = azurerm_container_registry.container_registry.login_server
  container_registry_username = azurerm_container_registry.container_registry.admin_username
  container_registry_password = azurerm_container_registry.container_registry.admin_password
  blob_storage_event_docker_image_name = var.blob_storage_event_docker_image_name
  blob_storage_event_docker_image_tag = var.blob_storage_event_docker_image_tag
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  storage_account_name = data.azurerm_storage_account.primary_storage_account.name
  primary_storage_account_id = data.azurerm_storage_account.primary_storage_account.id
  backend_resource_group_name = azurerm_resource_group.backend_resources.name
  backend_resource_location = azurerm_resource_group.backend_resources.location
  firmware_container_name = azurerm_storage_container.firmwares_container.name
  external_service_base_url = var.external_service_base_url
  key_vault_name = var.key_vault_name
  certificate_container_name = azurerm_storage_container.certificates_container.name
  devops_email = var.devops_email
  portal_resource_group = var.portal_resource_group
  blob_storage_trigger_function_name = var.blob_storage_trigger_function_name

  depends_on = [ 
    data.azurerm_key_vault.key_vault,
    data.azurerm_storage_account.primary_storage_account,
    null_resource.blob_storage_docker_image_push
  ]
}


module "databases" {
  source = "./modules/Databases"
  resource_prefix = var.resource_prefix
  key_vault_id = data.azurerm_key_vault.key_vault.id

  postgresql_allowed_connection_origins = concat(
    module.mobile_api_module.mobile_api_outbound_ip_list,
    module.web_api_module.web_api_outbound_ip_list,
    module.scheduler_module.scheduler_outbound_ip_list,
    module.iot_messenger_module.iot_messenger_outbound_ip_list,
    module.blob_storage_event_module.blob_storage_notfication_outbound_ip_list,
    module.smart_assistant_module.alexa_home_handler_outbound_list,
    module.smart_assistant_module.google_home_handler_out_bound_list
  )

  timescale_allowed_connection_origins = concat(
    module.mobile_api_module.mobile_api_outbound_ip_list,
    module.web_api_module.web_api_outbound_ip_list,
    module.scheduler_module.scheduler_outbound_ip_list,
    module.iot_messenger_module.iot_messenger_outbound_ip_list,
    module.blob_storage_event_module.blob_storage_notfication_outbound_ip_list,
    module.smart_assistant_module.alexa_home_handler_outbound_list,
    module.smart_assistant_module.google_home_handler_out_bound_list
  )

  resource_group_name = azurerm_resource_group.backend_resources.name
  resource_location = azurerm_resource_group.backend_resources.location
  timescale_subnet_id = azurerm_subnet.iot_network_timescale_subnet.id
  postgresql_subnet_id = azurerm_subnet.iot_network_postgresql_subnet.id
  postgresql_db_creds_key_name = var.postgresql_db_creds_key_name
  timescale_db_creds_key_name = var.timescale_db_creds_key_name
  environment = var.environment
  devops_email = var.devops_email

  depends_on = [ 
    module.mobile_api_module,
    module.web_api_module,
    module.scheduler_module,
    module.iot_messenger_module,
    module.blob_storage_event_module,
    module.smart_assistant_module
  ]
}
