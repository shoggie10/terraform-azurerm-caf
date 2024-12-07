
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
resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.db_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.db_throughput != null ? null : var.db_max_throughput

  autoscale_settings {
    max_throughput = var.db_max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "this" {
  name                = var.container_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = var.db_name
  partition_key_path  = var.partition_key_path
  partition_key_version = var.partition_key_version != null ? var.partition_key_version : 2
  throughput          = var.container_throughput != null ? null : var.container_max_throughput
  default_ttl         = var.default_ttl
  analytical_storage_ttl = var.analytical_storage_ttl

  indexing_policy {
    indexing_mode = var.indexing_mode
    included_path {
      path = var.included_path
    }
    excluded_path {
      path = var.excluded_path
    }
    composite_index {
      for_each = var.composite_index
      index {
        path  = each.value.index[0].path
        order = each.value.index[0].order
      }
    }
    spatial_index {
      path = var.spatial_path
    }
  }

  unique_key {
    paths = var.unique_key_paths
  }

  conflict_resolution_policy {
    mode = var.conflict_resolution_policy
  }
}


# variables.tf
----------
variable "db_name" {
  description = "The name of the Cosmos DB SQL database."
  type        = string
}

variable "db_throughput" {
  description = "The throughput for the database. If null, the database will be autoscaled."
  type        = number
  default     = null
}

variable "db_max_throughput" {
  description = "The maximum throughput to use for autoscaling the database."
  type        = number
  default     = 400
}

variable "container_name" {
  description = "The name of the Cosmos DB SQL container."
  type        = string
}

variable "partition_key_path" {
  description = "The path to use as the partition key for the container."
  type        = string
}

variable "partition_key_version" {
  description = "The version of the partition key for the container."
  type        = number
  default     = 2
}

variable "container_throughput" {
  description = "The throughput for the container. If null, the container will be autoscaled."
  type        = number
  default     = null
}

variable "container_max_throughput" {
  description = "The maximum throughput to use for autoscaling the container."
  type        = number
  default     = 400
}

variable "default_ttl" {
  description = "The default TTL (time-to-live) for the container."
  type        = number
  default     = null
}

variable "analytical_storage_ttl" {
  description = "The TTL for analytical storage."
  type        = number
  default     = null
}

variable "indexing_mode" {
  description = "The indexing mode for the container."
  type        = string
  default     = "Consistent"
}

variable "included_path" {
  description = "Included path for indexing."
  type        = string
  default     = "/*"
}

variable "excluded_path" {
  description = "Excluded path for indexing."
  type        = string
  default     = "/\"_etag\"/?"
}

variable "index_path" {
  description = "Path for indexing."
  type        = string
  default     = "/\"_ts\"/?"
}

variable "index_order" {
  description = "Order for indexing."
  type        = string
  default     = "Ascending"
}

variable "spatial_path" {
  description = "Path for spatial indexing."
  type        = string
  default     = "/\"location\"/?"
}

variable "unique_key_paths" {
  description = "Paths for the unique key in the container."
  type        = list(string)
  default     = []
}

variable "conflict_resolution_policy" {
  description = "The conflict resolution policy for the container."
  type        = string
  default     = "LastWriterWins"
}

variable "composite_index" {
  description = "List of composite indexes for the Cosmos DB SQL container."
  type = list(object({
    index = list(object({
      path  = string
      order = string
    }))
  }))
  default = []
}


# locals.tf
------------
locals {
  database_throughput = var.db_throughput != null ? var.db_throughput : var.db_max_throughput
  container_throughput = var.container_throughput != null ? var.container_throughput : var.container_max_throughput
}


# outputs.tf
----------
output "cosmosdb_sql_database_id" {
  description = "The ID of the Cosmos DB SQL database."
  value       = azurerm_cosmosdb_sql_database.this.id
}

output "cosmosdb_sql_container_id" {
  description = "The ID of the Cosmos DB SQL container."
  value       = azurerm_cosmosdb_sql_container.this.id
}

output "cosmosdb_sql_database_name" {
  description = "The name of the Cosmos DB SQL database."
  value       = azurerm_cosmosdb_sql_database.this.name
}

output "cosmosdb_sql_container_name" {
  description = "The name of the Cosmos DB SQL container."
  value       = azurerm_cosmosdb_sql_container.this.name
}


# examples.tf
-----------
module "cosmosdb_sql" {
  source              = "./path/to/your/module"
  db_name             = "example-database"
  db_throughput       = 1000
  db_max_throughput   = 4000
  container_name      = "example-container"
  partition_key_path  = "/id"
  container_throughput = 400
  container_max_throughput = 1000
  default_ttl         = 3600
  indexing_mode       = "Consistent"
  included_path       = "/*"
  excluded_path       = "/\"_etag\"/?"
  index_path          = "/\"_ts\"/?"
  index_order         = "Ascending"
  spatial_path        = "/\"location\"/?"
  unique_key_paths    = ["/\"email\""]
  conflict_resolution_policy = "LastWriterWins"

module "cosmosdb_sql" {
  source              = "./path/to/your/module"
  db_name             = "example-database"
  db_throughput       = 1000
  db_max_throughput   = 4000
  container_name      = "example-container"
  partition_key_path  = "/id"
  container_throughput = 400
  container_max_throughput = 1000
  default_ttl         = 3600
  indexing_mode       = "Consistent"
  included_path       = "/*"
  excluded_path       = "/\"_etag\"/?"
  index_path          = "/\"_ts\"/?"
  index_order         = "Ascending"
  spatial_path        = "/\"location\"/?"
  unique_key_paths    = ["/\"email\""]
  conflict_resolution_policy = "LastWriterWins"

  composite_index = [
    {
      index = [
        {
          path  = "/\"lastName\""
          order = "Ascending"
        },
        {
          path  = "/\"firstName\""
          order = "Descending"
        }
      ]
    }
  ]
}

output "cosmosdb_sql_database_id" {
  value = module.cosmosdb_sql.cosmosdb_sql_database_id
}

output "cosmosdb_sql_container_id" {
  value = module.cosmosdb_sql.cosmosdb_sql_container_id
}


}

output "cosmosdb_sql_database_id" {
  value = module.cosmosdb_sql.cosmosdb_sql_database_id
}

output "cosmosdb_sql_container_id" {
  value = module.cosmosdb_sql.cosmosdb_sql_container_id
}















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
