resource "azurerm_resource_group" "container_hub" {
  name     = "${var.resource_prefix}-container-resource-group"
  location = var.resource_location
}

resource "azurerm_container_registry" "container_registry" {
  name                = "${var.resource_prefix}containerregistry"
  resource_group_name = azurerm_resource_group.container_hub.name
  location            = azurerm_resource_group.container_hub.location
  sku                 = "Standard"
  admin_enabled       = true

  depends_on = [ azurerm_resource_group.container_hub ]
}

resource "null_resource" "acr_login" {
  triggers = {
    web_api_docker_image_name = var.web_api_docker_image_name
    web_api_docker_image_tag = var.web_api_docker_image_tag
    mobile_api_docker_image_name = var.mobile_api_docker_image_name
    mobile_api_docker_image_tag = var.mobile_api_docker_image_tag
    scheduler_docker_image_name = var.scheduler_docker_image_name
    scheduler_docker_image_tag = var.scheduler_docker_image_tag
    iot_messenger_docker_image_name = var.iot_messenger_docker_image_name
    iot_messenger_docker_image_tag = var.iot_messenger_docker_image_tag
  }
  provisioner "local-exec" {
    command = "az acr login --name ${azurerm_container_registry.container_registry.name}"
  }
}

resource "null_resource" "docker_login" {
  triggers = {
    web_api_docker_image_name = var.web_api_docker_image_name
    web_api_docker_image_tag = var.web_api_docker_image_tag
    mobile_api_docker_image_name = var.mobile_api_docker_image_name
    mobile_api_docker_image_tag = var.mobile_api_docker_image_tag
    scheduler_docker_image_name = var.scheduler_docker_image_name
    scheduler_docker_image_tag = var.scheduler_docker_image_tag
    iot_messenger_docker_image_name = var.iot_messenger_docker_image_name
    iot_messenger_docker_image_tag = var.iot_messenger_docker_image_tag
  }

  provisioner "local-exec" {
    command = "echo ${azurerm_container_registry.container_registry.admin_password} | docker login ${azurerm_container_registry.container_registry.login_server} --username ${azurerm_container_registry.container_registry.admin_username} --password-stdin"
  }

  depends_on = [ null_resource.acr_login ]
}


######### Mobile API Image Build ###################

resource "null_resource" "mobile_api_image_tagging" {
  triggers = {
    mobile_api_docker_image_name = var.mobile_api_docker_image_name
    mobile_api_docker_image_tag = var.mobile_api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.mobile_api_docker_image_name}:${var.mobile_api_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.mobile_api_docker_image_name}:${var.mobile_api_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}


resource "null_resource" "mobile_api_docker_image_push" {
  triggers = {
    mobile_api_docker_image_name = var.mobile_api_docker_image_name
    mobile_api_docker_image_tag = var.mobile_api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.mobile_api_docker_image_name}:${var.mobile_api_docker_image_tag}"
  }

  depends_on = [ null_resource.mobile_api_image_tagging ]
}



######### Web API Image Build ###################


resource "null_resource" "web_api_image_tagging" {
  triggers = {
    web_api_docker_image_name = var.web_api_docker_image_name
    web_api_docker_image_tag = var.web_api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.web_api_docker_image_name}:${var.web_api_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.web_api_docker_image_name}:${var.web_api_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "web_api_docker_image_push" {
  triggers = {
    web_api_docker_image_name = var.web_api_docker_image_name
    web_api_docker_image_tag = var.web_api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.web_api_docker_image_name}:${var.web_api_docker_image_tag}"
  }

  depends_on = [ null_resource.web_api_image_tagging ]
}



######### Scheduler Image Build ###################


resource "null_resource" "scheduler_image_tagging" {
  triggers = {
    scheduler_docker_image_name = var.scheduler_docker_image_name
    scheduler_docker_image_tag = var.scheduler_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.scheduler_docker_image_name}:${var.scheduler_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.scheduler_docker_image_name}:${var.scheduler_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "scheduler_docker_image_push" {
  triggers = {
    scheduler_docker_image_name = var.scheduler_docker_image_name
    scheduler_docker_image_tag = var.scheduler_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.scheduler_docker_image_name}:${var.scheduler_docker_image_tag}"
  }

  depends_on = [ null_resource.scheduler_image_tagging ]
}





######### IoT Messenger Image Build ###################


resource "null_resource" "iot_messenger_image_tagging" {
  triggers = {
    iot_messenger_docker_image_name = var.iot_messenger_docker_image_name
    iot_messenger_docker_image_tag = var.iot_messenger_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.iot_messenger_docker_image_name}:${var.iot_messenger_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.iot_messenger_docker_image_name}:${var.iot_messenger_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "iot_messenger_docker_image_push" {
  triggers = {
    iot_messenger_docker_image_name = var.iot_messenger_docker_image_name
    iot_messenger_docker_image_tag = var.iot_messenger_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.iot_messenger_docker_image_name}:${var.iot_messenger_docker_image_tag}"
  }

  depends_on = [ null_resource.iot_messenger_image_tagging ]
}





######### Blob Storage Trigger Function Image Build ###################


resource "null_resource" "blob_storage_image_tagging" {
  triggers = {
    blob_storage_event_docker_image_name = var.blob_storage_event_docker_image_name
    blob_storage_event_docker_image_tag = var.blob_storage_event_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.blob_storage_event_docker_image_name}:${var.blob_storage_event_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.blob_storage_event_docker_image_name}:${var.blob_storage_event_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "blob_storage_docker_image_push" {
  triggers = {
    blob_storage_event_docker_image_name = var.blob_storage_event_docker_image_name
    blob_storage_event_docker_image_tag = var.blob_storage_event_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.blob_storage_event_docker_image_name}:${var.blob_storage_event_docker_image_tag}"
  }

  depends_on = [ null_resource.blob_storage_image_tagging ]
}


######### Smart Asistant Manager Function Image Build ###################


resource "null_resource" "smart_assistant_manager_image_tagging" {
  triggers = {
    smart_assistant_manager_docker_image_name = var.smart_assistant_manager_docker_image_name
    smart_assistant_manager_docker_image_tag = var.smart_assistant_manager_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.smart_assistant_manager_docker_image_name}:${var.smart_assistant_manager_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.smart_assistant_manager_docker_image_name}:${var.smart_assistant_manager_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "smart_assistant_manager_image_push" {
  triggers = {
    smart_assistant_manager_docker_image_name = var.smart_assistant_manager_docker_image_name
    smart_assistant_manager_docker_image_tag = var.smart_assistant_manager_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.smart_assistant_manager_docker_image_name}:${var.smart_assistant_manager_docker_image_tag}"
  }

  depends_on = [ null_resource.smart_assistant_manager_image_tagging ]
}



######### Google Home Function Image Build ###################


resource "null_resource" "google_home_handler_image_tagging" {
  triggers = {
    google_home_handler_docker_image_name = var.google_home_handler_docker_image_name
    google_home_handler_docker_image_tag = var.google_home_handler_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.google_home_handler_docker_image_name}:${var.google_home_handler_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.google_home_handler_docker_image_name}:${var.google_home_handler_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "google_home_handler_image_push" {
  triggers = {
    google_home_handler_docker_image_name = var.google_home_handler_docker_image_name
    google_home_handler_docker_image_tag = var.google_home_handler_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.google_home_handler_docker_image_name}:${var.google_home_handler_docker_image_tag}"
  }

  depends_on = [ null_resource.google_home_handler_image_tagging ]
}





######### Alexa Handler Function Image Build ###################


resource "null_resource" "alexa_handler_image_tagging" {
  triggers = {
    alexa_home_handler_docker_image_name = var.alexa_home_handler_docker_image_name
    alexa_home_handler_docker_image_tag = var.alexa_home_handler_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.alexa_home_handler_docker_image_name}:${var.alexa_home_handler_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.alexa_home_handler_docker_image_name}:${var.alexa_home_handler_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "alexa_handler_image_push" {
  triggers = {
    alexa_home_handler_docker_image_name = var.alexa_home_handler_docker_image_name
    smart_assistant_manager_docker_image_tag = var.alexa_home_handler_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.alexa_home_handler_docker_image_name}:${var.alexa_home_handler_docker_image_tag}"
  }

  depends_on = [ null_resource.alexa_handler_image_tagging ]
}
