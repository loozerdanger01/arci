resource "azurerm_resource_group" "network_resource_group" {
  name     = "${var.resource_prefix}-network-resources"
  location = var.resource_location
}

# Azure virtual Network
resource "azurerm_virtual_network" "iot_network" {
  name                = "${var.resource_prefix}-iot-vpc-network"
  resource_group_name = azurerm_resource_group.network_resource_group.name
  location            = azurerm_resource_group.network_resource_group.location
  address_space       = [var.vpc_address_space]

  tags = {
    developer = "IoTfy"
    environment = var.environment
  }
}


# Azure Postgresql Subnet
resource "azurerm_subnet" "iot_network_postgresql_subnet" {
  name                 = "${var.resource_prefix}-iot-postgresql-subnet"
  resource_group_name  = azurerm_resource_group.network_resource_group.name
  virtual_network_name = azurerm_virtual_network.iot_network.name
  address_prefixes     = [var.postgresql_subnet_space]
}


# Azure Timescale Subnet
resource "azurerm_subnet" "iot_network_timescale_subnet" {
  name                 = "${var.resource_prefix}-iot-timescale-subnet"
  resource_group_name  = azurerm_resource_group.network_resource_group.name
  virtual_network_name = azurerm_virtual_network.iot_network.name
  address_prefixes     = [var.timescale_subnet_space]
}


resource "azurerm_route_table" "iot_route_table" {
  name                          = "${var.resource_prefix}-iot-route-table"
  resource_group_name = azurerm_resource_group.network_resource_group.name
  location            = azurerm_resource_group.network_resource_group.location
  disable_bgp_route_propagation = false

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    developer = "IoTfy"
    environment = var.environment
  }
}


resource "azurerm_subnet_route_table_association" "postgresql_subnet_route_association" {
  subnet_id      = azurerm_subnet.iot_network_postgresql_subnet.id
  route_table_id = azurerm_route_table.iot_route_table.id
}


resource "azurerm_subnet_route_table_association" "timescale_subnet_route_association" {
  subnet_id      = azurerm_subnet.iot_network_timescale_subnet.id
  route_table_id = azurerm_route_table.iot_route_table.id
}


