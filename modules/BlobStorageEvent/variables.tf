variable "resource_prefix" {
  type = string
  description = "Resource prefix for the resource"
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
  description = "Storage account name"
  nullable = false
}

variable "storage_account_access_key" {
  type = string
  description = "Storage account name"
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
  description = "Container registry username"
  nullable = false
}

variable "container_registry_password" {
  type = string
  description = "Container registry password"
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

variable "key_vault_name" {
  type = string
  description = "Key vault name"
  nullable = false 
}

variable "certificate_container_name" {
  type = string
  description = "Certificate container name"
  nullable = false
}

variable "devops_email" {
  type = string
  description = "DevOps Email"
  nullable = false
}

variable "portal_resource_group" {
  type = string
  description = "Portal resource group name"
  nullable = false
}


variable "blob_storage_trigger_function_name" {
  type = string
  description = "Blog storage event trigger function name"
  nullable = false
}