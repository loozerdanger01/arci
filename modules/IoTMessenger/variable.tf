variable "resource_prefix" {
  type = string
  description = "resource prefix for the resource"
  nullable = false
}

variable "backend_resource_location" {
  type = string
  description = "Resource location"
  nullable = false
}

variable "backend_resource_group_name" {
  type = string
  description = "Resource group name"
  nullable = false
}

variable "primary_storage_account_id" {
  type = string
  description = "Primary storage account id"
  nullable = false
}

variable "storage_account_name" {
  type = string
  description = "storage account name"
  nullable = false
}

variable "storage_account_access_key" {
  type = string
  description = "storage account name"
  nullable = false
}

variable "key_vault_id" {
  type = string
  description = "key vault id"
  nullable = false
}

variable "key_vault_name" {
  type = string
  description = "key vault name"
  nullable = false 
}

variable "acr_container_registry_id" {
  type = string
  description = "acr container registry id"
  nullable = false
}

variable "container_registry_url" {
  type = string
  description = "Container registry url"
  nullable = false
}


variable "container_registry_username" {
  type = string
  description = "container registry username"
  nullable = false
}


variable "container_registry_password" {
  type = string
  description = "container registry password"
  nullable = false
}

variable "iot_messenger_docker_image_name" {
  type = string
  description = "iot_messenger docker image name"
  nullable = false
}

variable "iot_messenger_docker_image_tag" {
  type = string
  description = "iot_messenger docker image tag"
  nullable = false
}

variable "environment" {
  type = string
  description = "Environment"
  nullable = false
}

variable "firmware_container_name" {
  type = string
  description = "Firmware container name"
  nullable = false
}

variable "external_service_base_url" {
  type = string
  description = "External service base url"
  nullable = false
}

variable "certificate_container_name" {
  type = string
  description = "certificate container name"
  nullable = false
}


variable "devops_email" {
  type = string
  description = "DevOps Email"
  nullable = false
}

variable "smart_assistant_manager_handler_base_url" {
  type = string
  description = "Smart Assistant Manager base url"
  nullable = false
}