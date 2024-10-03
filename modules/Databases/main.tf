
data "azurerm_key_vault_secret" "postgresql_db_creds_secret_data" {
  name         = var.postgresql_db_creds_key_name
  key_vault_id = var.key_vault_id
}


data "azurerm_key_vault_secret" "timescale_db_creds_secret_data" {
  name         = var.timescale_db_creds_key_name
  key_vault_id = var.key_vault_id
}

resource "azurerm_resource_group" "backup_and_recovery" {
  name     = "${var.resource_prefix}-backup-and-recovery-resources"
  location = var.resource_location
}


resource "azurerm_recovery_services_vault" "backup_vault" {
  name                = "${var.resource_prefix}-backup-recovery-vault"
  location            = azurerm_resource_group.backup_and_recovery.location
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  sku                 = "Standard"
  public_network_access_enabled = true
  soft_delete_enabled = false

  tags = {
    developer = "IoTfy"
    environment = var.environment
  }
}



# Failure Notification

resource "azurerm_monitor_action_group" "backup_failure_action" {
  name                = "${var.resource_prefix}-database-backup-failure-action"
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  short_name          = "db-bkup-fail"

  email_receiver {
    name                    = "sendtodevops"
    email_address           = "yogesh.bisht@iotfy.co"
    use_common_alert_schema = true
  }

  tags = {
    developer = "IoTfy"
    environment = var.environment
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "backup_failure_metric_rule" {
  name                = "${var.resource_prefix}-database-backup-failure-alert"
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  scopes              = [azurerm_recovery_services_vault.backup_vault.id]
  location            = azurerm_resource_group.backup_and_recovery.location
  criteria {
    query                   = <<-QUERY
      AddonAzureBackupJobs
      | summarize arg_max(TimeGenerated,*) by JobUniqueId
      | where JobStatus == "Failed"
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
    action_groups = [azurerm_monitor_action_group.backup_failure_action.id]
  }
}


module "postgresql_database" {
  source = "./Postgresql"
  database_name              = jsondecode(data.azurerm_key_vault_secret.postgresql_db_creds_secret_data.value)["dbName"]
  database_user              = jsondecode(data.azurerm_key_vault_secret.postgresql_db_creds_secret_data.value)["username"]
  database_password          = jsondecode(data.azurerm_key_vault_secret.postgresql_db_creds_secret_data.value)["password"]
  database_port              = "5433"
  resource_group_name        = var.resource_group_name
  postgresql_subnet_id       = var.postgresql_subnet_id
  resource_prefix            = var.resource_prefix
  resource_location          = var.resource_location
  database_disk_size         = 50 # GiB
  allowed_connection_origins = var.postgresql_allowed_connection_origins
  environment = var.environment
  depends_on = [ azurerm_monitor_scheduled_query_rules_alert_v2.backup_failure_metric_rule ]
}


module "timescale_database" {
  source = "./Timescale"
  database_name              = jsondecode(data.azurerm_key_vault_secret.timescale_db_creds_secret_data.value)["dbName"]
  database_user              = jsondecode(data.azurerm_key_vault_secret.timescale_db_creds_secret_data.value)["username"]
  database_password          = jsondecode(data.azurerm_key_vault_secret.timescale_db_creds_secret_data.value)["password"]
  database_port              = "5433"
  resource_group_name        = var.resource_group_name
  timescale_subnet_id        = var.postgresql_subnet_id
  resource_prefix            = var.resource_prefix
  resource_location          = var.resource_location
  database_disk_size         = 50 # GiB
  allowed_connection_origins = var.timescale_allowed_connection_origins
  environment                = var.environment
  depends_on = [ azurerm_monitor_scheduled_query_rules_alert_v2.backup_failure_metric_rule ]

}



resource "azurerm_backup_policy_vm" "postgresql_database_vm_backup_policy" {
  name                = "${var.resource_prefix}-postgresql-database-vm-backup-policy"
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "20:30" # Morning 2'0 Clock as per IST
  }

  instant_restore_retention_days = 2

  retention_daily {
    count = 7
  }
}


resource "azurerm_backup_policy_vm" "timescale_database_vm_backup_policy" {
  name                = "${var.resource_prefix}-timescale-database-vm-backup-policy"
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "20:30" # Morning 2'0 Clock as per IST
  }

  instant_restore_retention_days = 2

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "postgresql_database_backup" {
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id        = module.postgresql_database.virtual_machine_id
  backup_policy_id    = azurerm_backup_policy_vm.postgresql_database_vm_backup_policy.id

  depends_on = [ module.postgresql_database ]
}

resource "azurerm_backup_protected_vm" "timescale_database_backup" {
  resource_group_name = azurerm_resource_group.backup_and_recovery.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id        = module.timescale_database.virtual_machine_id
  backup_policy_id    = azurerm_backup_policy_vm.timescale_database_vm_backup_policy.id

  depends_on = [ module.timescale_database ]
}



# Monitor_Action_group
resource "azurerm_monitor_action_group" "database_monitor_action_group" {
  name                = "${var.resource_prefix}-azure-monitor-grp-name"
  resource_group_name = var.resource_group_name
  short_name          = "db_mntr_actn"

  email_receiver {
    name          = "devloper_iotfy"
    email_address = var.devops_email
  }
}


# CPU Processing_metric_alert

resource "azurerm_monitor_metric_alert" "postgresql_cpu_metric_alert" {
  name                = "${var.resource_prefix}-postgresql-cpu-metric-alert"
  resource_group_name = var.resource_group_name
  scopes              = [module.postgresql_database.virtual_machine_id]
  frequency           = "PT5M"
  window_size         = "PT5M"   
  severity            =  0

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        =  75
  }
  action {
    action_group_id = azurerm_monitor_action_group.database_monitor_action_group.id
  }
}


# Alert for available memory bytes postgresql

resource "azurerm_monitor_metric_alert" "postgresql_memory_utilization_alert" {
  name                = "${var.resource_prefix}-postgresql-memory-utilization-alert"
  resource_group_name = var.resource_group_name
  description         = "Alert when available memory is less than 512 MB"

  scopes              =  [module.postgresql_database.virtual_machine_id]
  frequency           =  "PT5M"
  window_size         =  "PT5M"   
  severity            =    0

  criteria {
    metric_namespace = "microsoft.compute/virtualmachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        =  536870912  # 512 MB in bytes
                                                                                                                                                                                    
  }

  action {
    action_group_id = azurerm_monitor_action_group.database_monitor_action_group.id
  }
}

# CPU Processing_metric_alert for timescaledb

resource "azurerm_monitor_metric_alert" "timescaledb_cpu_metric_alert" {
  name                = "${var.resource_prefix}-timescaledb-cpu-metric-alert"
  resource_group_name = var.resource_group_name
  scopes              = [module.timescale_database.virtual_machine_id]
  frequency           = "PT5M"
  window_size         = "PT5M"
  severity            =   0
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        =  75
  }
  action {
    action_group_id = azurerm_monitor_action_group.database_monitor_action_group.id
  }
}


# Alerts for available memory bytes timescaledb

resource "azurerm_monitor_metric_alert" "timescaledb_memory_utilization_alert" {
  name                = "${var.resource_prefix}-timescaledb-memory-utilization-alert"
  resource_group_name = var.resource_group_name
  description         = "Alert when available memory is less than 512 MB"

  scopes             =  [module.timescale_database.virtual_machine_id]
  frequency          =  "PT5M"
  window_size        =  "PT5M"
  severity           =    0

  criteria {
    metric_namespace = "microsoft.compute/virtualmachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        =  536870912        # 512 MB in bytes
  }

  action {
    action_group_id = azurerm_monitor_action_group.database_monitor_action_group.id
  }
}


