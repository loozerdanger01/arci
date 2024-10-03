variable "resource_location" {
  type = string
  description = "Resource location"
  nullable = false
}

variable "resource_group_name" {
  type = string
  description = "Resource group name"
  nullable = false
}

variable "postgresql_subnet_id" {
  type = string
  description = "Subnet id of the postgresql subnet"
  nullable = false
}

variable "posgresql_instance_size" {
  type = string
  description = "Postgresql instance size or type"
  nullable = false
  default = "Standard_B2s"
}

variable "vpc_address_space" {
  type = string
  description = "Address space for vpc"
  nullable = false
  default = "10.0.0.0/16"
}


variable "database_user"{
    type = string
    description = "Username of postgresql database"
    nullable = false
}

variable "database_password"{
    type = string
    description = "Password of postgresql database"
    nullable = false
}

variable "database_name"{
    type = string
    description = "Name of postgresql database"
    nullable = false
}

variable "database_port"{
    type = string
    description = "Port of postgresql database"
    nullable = false
}

variable "resource_prefix" {
  type = string
  description = "resource prefix for the resource"
  nullable = false
}


variable "database_disk_size" {
  type = string
  description = "database disk size"
  nullable =  false
}

variable "allowed_connection_origins" {
  type = list(string)
  description = "allowed connection origin on port 5432"
  nullable =  false
}

variable "environment" {
  type = string
  description = "Environment"
  nullable =  false
}

