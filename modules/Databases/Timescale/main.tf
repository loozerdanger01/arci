
resource "azurerm_public_ip" "timescale_public_ip" {
  name                = "timescale-instance-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  allocation_method   = "Static"

  tags = {
    environment = var.environment
    developer = "IoTfy"
  }
}

resource "azurerm_network_interface" "iot_network_timescale_subnet_interface" {
  name                = "${var.resource_prefix}-iot-timescale-subnet-interface"
  resource_group_name = var.resource_group_name
  location            = var.resource_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.timescale_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.timescale_public_ip.id
    primary = true
  }
}


resource "azurerm_network_security_group" "timescale_subnet_interface_sg" {
  name                = "timescale-subnet-interface-sg"
  resource_group_name = var.resource_group_name
  location            = var.resource_location

  security_rule {
    name                       = "AllowSSHConnection"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
  
    destination_address_prefix = "*"
    destination_port_range     = "22"
  
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    name                       = "AllowFromAppService"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
  
    source_port_range          = "*"
    source_address_prefixes    = var.allowed_connection_origins
  
    destination_port_range     = var.database_port
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    developer = "IoTfy"
  }
}


resource "tls_private_key" "timescale_instance_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "null_resource" "save_timescale_instance_private_key" {
  triggers = {
    private_key = tls_private_key.timescale_instance_private_key.private_key_pem
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.timescale_instance_private_key.private_key_pem}' > timescale-instance-pvt-key.pem"
  }
}


resource "azurerm_managed_disk" "timescale_instance_data_storage" {
  name                 = "timescale-instance-data-storage"
  resource_group_name  = var.resource_group_name
  location             = var.resource_location
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.database_disk_size
}



resource "azurerm_linux_virtual_machine" "timescale_instance" {
  name                = "timescale-db-intance"
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  size                = "Standard_B2s"
  admin_username      = "iotfy"
  network_interface_ids = [azurerm_network_interface.iot_network_timescale_subnet_interface.id]

  admin_ssh_key {
    username   = "iotfy"
    public_key = tls_private_key.timescale_instance_private_key.public_key_openssh
  }

  os_disk {
    name                 = "postgresql-instance-storage"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/init.sh",
    {
      VpcCIDR         = var.vpc_address_space
      DatabaseUser    = var.database_user
      DatabasePassword= var.database_password
      DatabaseName    = var.database_name
      DatabasePort    = var.database_port
    }
  ))

  lifecycle {
    ignore_changes = [custom_data]
  }
}


resource "azurerm_virtual_machine_data_disk_attachment" "timescale_storage_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.timescale_instance_data_storage.id
  virtual_machine_id = azurerm_linux_virtual_machine.timescale_instance.id
  lun                = "1"
  caching            = "ReadWrite"
}


resource "azurerm_network_interface_security_group_association" "timescale_network_interface_security_group_association" {
  network_interface_id      = azurerm_network_interface.iot_network_timescale_subnet_interface.id
  network_security_group_id = azurerm_network_security_group.timescale_subnet_interface_sg.id
}