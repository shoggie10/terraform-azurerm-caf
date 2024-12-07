
module "keyvaults" {
  source   = "./modules/security/keyvault"
  for_each = var.keyvaults

  global_settings    = local.global_settings
  client_config      = local.client_config
  settings           = each.value
  diagnostics        = local.combined_diagnostics
  vnets              = local.combined_objects_networking
  virtual_subnets    = local.combined_objects_virtual_subnets
  azuread_groups     = local.combined_objects_azuread_groups
  managed_identities = local.combined_objects_managed_identities
  private_dns        = local.combined_objects_private_dns

  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)
}

#
# Keyvault access policies
#-
===============================================================================================
# main.tf
-------
resource "azurerm_cosmosdb_cassandra_keyspace" "this" {
  name                = var.keyspace_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.keyspace_max_throughput != null ? null : var.keyspace_throughput

  autoscale_settings {
    max_throughput = var.keyspace_max_throughput
  }
}

resource "azurerm_cosmosdb_cassandra_table" "this" {
  name                   = var.table_name
  cassandra_keyspace_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.this.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.this.name}/cassandraKeyspaces/${var.keyspace_name}"
  throughput             = var.table_max_throughput != null ? null : var.table_throughput
  default_ttl            = var.default_ttl_seconds != null ? var.default_ttl_seconds : null
  analytical_storage_ttl = var.analytical_storage_ttl != null ? var.analytical_storage_ttl : null

  autoscale_settings {
    max_throughput = var.table_max_throughput
  }

  schema {
    column {
      name = var.column_name
      type = var.column_type
    }

    partition_key {
      name = var.partition_key_name
    }

    cluster_key {
      name     = var.cluster_key_name
      order_by = var.cluster_key_order_by
    }
  }

  depends_on = [
    azurerm_cosmosdb_cassandra_keyspace.this
  ]
}




# variables.tf
----------
variable "keyspace_name" {
  description = "The name of the Cosmos DB Cassandra keyspace."
  type        = string
}

variable "keyspace_throughput" {
  description = "The throughput for the keyspace."
  type        = number
  default     = 400
}

variable "keyspace_max_throughput" {
  description = "The maximum throughput for autoscaling the keyspace."
  type        = number
  default     = 4000
}


variable "table_name" {
  description = "The name of the Cassandra table."
  type        = string
}

variable "table_throughput" {
  description = "The throughput for the table."
  type        = number
  default     = 400
}

variable "table_max_throughput" {
  description = "The maximum throughput for autoscaling the table."
  type        = number
  default     = 4000
}

variable "default_ttl_seconds" {
  description = "The TTL (time-to-live) for the table."
  type        = number
  default     = null
}

variable "analytical_storage_ttl" {
  description = "The TTL for analytical storage."
  type        = number
  default     = null
}

variable "column_name" {
  description = "The name of the Cassandra column."
  type        = string
}

variable "column_type" {
  description = "The type of the Cassandra column."
  type        = string
}

variable "partition_key_name" {
  description = "The name of the partition key for the table."
  type        = string
}

variable "cluster_key_name" {
  description = "The name of the cluster key for the table."
  type        = string
}

variable "cluster_key_order_by" {
  description = "The order by for the cluster key."
  type        = string
  default     = "Ascending"
}

variable "keyspace_throughput" {
  description = "The throughput for the keyspace."
  type        = number
  default     = 400
  validation {
    condition     = var.keyspace_throughput >= 400
    error_message = "Keyspace throughput must be greater than or equal to 400."
  }
}



# locals.tf
------------
locals {
  keyspace_throughput = var.keyspace_throughput != null ? var.keyspace_throughput : var.keyspace_max_throughput
  table_throughput    = var.table_throughput != null ? var.table_throughput : var.table_max_throughput
}





# outputs.tf
----------
output "cosmosdb_cassandra_keyspace_id" {
  description = "The ID of the Cosmos DB Cassandra keyspace."
  value       = azurerm_cosmosdb_cassandra_keyspace.this.id
}

output "cosmosdb_cassandra_table_id" {
  description = "The ID of the Cosmos DB Cassandra table."
  value       = azurerm_cosmosdb_cassandra_table.this.id
}





# examples.tf
-----------
module "cosmosdb_cassandra" {
  source              = "./path/to/your/module"
  keyspace_name       = "example-keyspace"
  keyspace_throughput = 1000
  keyspace_max_throughput = 4000
  table_name          = "example-table"
  table_throughput    = 1000
  table_max_throughput = 4000
  default_ttl_seconds = 3600
  column_name         = "example_column"
  column_type         = "text"
  partition_key_name  = "id"
  cluster_key_name    = "timestamp"
  cluster_key_order_by = "Ascending"
}

output "cosmosdb_cassandra_keyspace_id" {
  value = module.cosmosdb_cassandra.cosmosdb_cassandra_keyspace_id
}

output "cosmosdb_cassandra_table_id" {
  value = module.cosmosdb_cassandra.cosmosdb_cassandra_table_id
}







===========||=========










======================================||=======================================================
======================================|\=======================================================

module "keyvault_access_policies" {
  source   = "./modules/security/keyvault_access_policies"
  for_each = var.keyvault_access_policies

  keyvault_key    = each.key
  keyvaults       = local.combined_objects_keyvaults
  access_policies = each.value
  azuread_groups  = local.combined_objects_azuread_groups
  client_config   = local.client_config
  resources = {
    azuread_service_principals        = local.combined_objects_azuread_service_principals
    diagnostic_storage_accounts       = local.combined_objects_diagnostic_storage_accounts
    managed_identities                = local.combined_objects_managed_identities
    mssql_managed_instances           = local.combined_objects_mssql_managed_instances
    mssql_managed_instances_secondary = local.combined_objects_mssql_managed_instances_secondary
    storage_accounts                  = local.combined_objects_storage_accounts
  }
}


# Need to separate keyvault policies from azure AD apps to get the keyvault with the default policies.
# Reason - Azure AD apps passwords are stored into keyvault secrets and combining would create a circular reference
module "keyvault_access_policies_azuread_apps" {
  source   = "./modules/security/keyvault_access_policies"
  for_each = var.keyvault_access_policies_azuread_apps

  keyvault_key    = each.key
  keyvaults       = local.combined_objects_keyvaults
  access_policies = each.value
  client_config   = local.client_config
  azuread_apps    = local.combined_objects_azuread_apps
}


output "keyvaults" {
  value = module.keyvaults

}
