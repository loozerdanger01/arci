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

variable "key_vault_id" {
  type = string
  description = "key vault id"
  nullable =  false
}


variable "postgresql_subnet_id" {
  type = string
  description = "postgresql subnet id"
  nullable =  false
}

variable "timescale_subnet_id" {
  type = string
  description = "postgresql subnet id"
  nullable =  false
}

variable "resource_prefix" {
  type = string
  description = "resource prefix"
  nullable = false
}

variable "resource_location" {
  type = string
  description = "resource location"
  nullable = false
}

variable "resource_group_name" {
  type = string
  description = "resource group name"
}

variable "timescale_allowed_connection_origins" {
  type = list(string)
  description = "allowed connection origin on port 5432 of timescale db"
  nullable =  false
}


variable "postgresql_allowed_connection_origins" {
  type = list(string)
  description = "allowed connection origin on port 5432 of postgresql db"
  nullable =  false
}

variable "environment" {
  type = string
  description = "Environment"
  nullable =  false
}

variable "devops_email" {
  type = string
  description = "devops email"
  nullable = false
}