variable "resource_prefix" {
  type = string
  description = "resource prefix for the resource"
  nullable = false
}

variable "resource_location" {
  type = string
  description = "resource location"
  nullable = false
}

variable "environment" {
  type = string
  description = "environment for the resource"
  nullable = false
}

variable "vpc_address_space" {
  type = string
  description = "Address space for vpc"
  nullable = false
  default = "10.0.0.0/16"
}

variable "postgresql_subnet_space" {
  type = string
  description = "Subnet space for postgresql subnet"
  nullable = false
  default = "10.0.1.0/24"
}

variable "timescale_subnet_space" {
  type = string
  description = "Subnet space for timescale subnet"
  nullable = false
  default = "10.0.2.0/24"
}

variable "company_email" {
  type = string
  description = "Comapy Email"
  nullable = false
}


variable "devops_email" {
  type = string
  description = "DevOps Email"
  nullable = false
}


variable "mobile_api_docker_image_name" {
  type = string
  description = "mobile api docker image name"
  nullable = false
}

variable "mobile_api_docker_image_tag" {
  type = string
  description = "mobile api docker image tag"
  nullable = false
}


variable "web_api_docker_image_name" {
  type = string
  description = "web api docker image name"
  nullable = false
}

variable "web_api_docker_image_tag" {
  type = string
  description = "web api docker image tag"
  nullable = false
}

variable "scheduler_docker_image_name" {
  type = string
  description = "scheduler docker image name"
  nullable = false
}

variable "scheduler_docker_image_tag" {
  type = string
  description = "scheduler docker image tag"
  nullable = false
}


variable "postgresql_db_creds_key_name" {
  type = string
  description = "postgresql database credential key name"
  nullable = false
}

variable "timescale_db_creds_key_name" {
  type = string
  description = "postgresql database credential key name"
  nullable = false
}

variable "key_vault_name" {
  type = string
  description = "key vault name"
  nullable =  false
}

variable "portal_resource_group" {
  type = string
  description = "key vault resource group"
  nullable =  false
}

variable "external_service_base_url" {
  type = string
  description = "External service base url"
  nullable = false
}

variable "storage_account_name" {
  type = string
  description = "storage account name"
}

variable "iot_messenger_docker_image_name" {
  type = string
  description = "iot_messenger docker image name"
  nullable = false
}

variable "smart_assistant_manager_docker_image_name" {
  type = string
  description = "smart assistant manager docker image name"
  nullable = false
}

variable "smart_assistant_manager_docker_image_tag" {
  type = string
  description = "smart assistant manager docker image tag"
  nullable = false
}
variable "google_home_handler_docker_image_name" {
  type = string
  description = "google home handler docker image name"
  nullable = false
}

variable "google_home_handler_docker_image_tag" {
  type = string
  description = "google home handler docker image tag"
  nullable = false
}
variable "alexa_home_handler_docker_image_name" {
  type = string
  description = "alexa home handler docker image name"
  nullable = false
}

variable "alexa_home_handler_docker_image_tag" {
  type = string
  description = "alexa home handler docker image tag"
  nullable = false
}


variable "iot_messenger_docker_image_tag" {
  type = string
  description = "iot_messenger docker image tag"
  nullable = false
}

variable "blob_storage_event_docker_image_name" {
  type = string
  description = "Blob storage event image name"
  nullable = false
}

variable "blob_storage_event_docker_image_tag" {
  type = string
  description = "Blob storage event docker image tag"
  nullable = false
}


variable "blob_storage_trigger_function_name" {
  type = string
  description = "Blog storage event trigger function name"
  nullable = false
}

variable "company_name" {
  type = string
  description = "Name of the company"
  nullable = false
}
