
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
resource "azurerm_cosmosdb_mongo_database" "this" {
  name                = var.db_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.db_throughput != null ? null : var.db_max_throughput

  autoscale_settings {
    max_throughput = var.db_max_throughput
  }

  validation {
    condition     = var.db_throughput >= 400
    error_message = "Throughput must be a positive number greater than or equal to 400."
  }
}

resource "azurerm_cosmosdb_mongo_collection" "this" {
  name                = var.collection_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = var.db_name
  default_ttl_seconds = var.default_ttl_seconds != null ? var.default_ttl_seconds : null
  shard_key           = var.shard_key
  throughput          = var.collection_throughput != null ? null : var.collection_max_throughput
  analytical_storage_ttl = var.analytical_storage_ttl != null ? var.analytical_storage_ttl : null

  index {
    keys  = var.mongo_index_keys
    unique = var.mongo_index_unique != null ? var.mongo_index_unique : false
  }

  depends_on = [
    azurerm_cosmosdb_mongo_database.this
  ]
}




# variables.tf
----------
variable "db_name" {
  description = "The name of the MongoDB database."
  type        = string
}

variable "db_throughput" {
  description = "The throughput for the MongoDB database. If null, autoscale is used."
  type        = number
  default     = null
}

variable "db_throughput" {
  description = "The throughput for the database. If null, the database will be autoscaled."
  type        = number
  default     = null
  validation {
    condition     = var.db_throughput >= 400
    error_message = "Throughput must be a positive number greater than or equal to 400."
  }
}


variable "db_max_throughput" {
  description = "The maximum throughput for the MongoDB database when autoscaling."
  type        = number
  default     = 400
}

variable "collection_name" {
  description = "The name of the MongoDB collection."
  type        = string
}

variable "db_name" {
  description = "The database name to associate with the MongoDB collection."
  type        = string
}

variable "shard_key" {
  description = "The shard key for the MongoDB collection."
  type        = string
}

variable "collection_throughput" {
  description = "The throughput for the MongoDB collection. If null, autoscale is used."
  type        = number
  default     = null
}

variable "collection_max_throughput" {
  description = "The maximum throughput for the MongoDB collection when autoscaling."
  type        = number
  default     = 400
}

variable "analytical_storage_ttl" {
  description = "The TTL (time-to-live) for analytical storage in the MongoDB collection."
  type        = number
  default     = null
}

variable "index_keys" {
  description = "The keys for indexing in the MongoDB collection."
  type        = list(string)
}

variable "index_unique" {
  description = "Whether the index should be unique."
  type        = bool
  default     = false
}



# locals.tf
------------
locals {
  database_throughput = var.db_throughput != null ? var.db_throughput : var.db_max_throughput
  collection_throughput = var.collection_throughput != null ? var.collection_throughput : var.collection_max_throughput
}




# outputs.tf
----------
output "cosmosdb_mongo_database_id" {
  description = "The ID of the Cosmos DB MongoDB database."
  value       = azurerm_cosmosdb_mongo_database.this.id
}

output "cosmosdb_mongo_collection_id" {
  description = "The ID of the Cosmos DB MongoDB collection."
  value       = azurerm_cosmosdb_mongo_collection.this.id
}

output "cosmosdb_mongo_database_name" {
  description = "The name of the Cosmos DB MongoDB database."
  value       = azurerm_cosmosdb_mongo_database.this.name
}

output "cosmosdb_mongo_collection_name" {
  description = "The name of the Cosmos DB MongoDB collection."
  value       = azurerm_cosmosdb_mongo_collection.this.name
}



# examples.tf
-----------
module "cosmosdb_mongo" {
  source            = "./path/to/your/module"
  db_name           = "example-mongo-database"
  db_throughput     = 1000
  db_max_throughput = 4000
  collection_name   = "example-mongo-collection"
  shard_key         = "id"
  collection_throughput = 400
  collection_max_throughput = 1000
  analytical_storage_ttl = 3600
  index_keys        = ["id", "email"]
  index_unique      = true
}

output "cosmosdb_mongo_database_id" {
  value = module.cosmosdb_mongo.cosmosdb_mongo_database_id
}

output "cosmosdb_mongo_collection_id" {
  value = module.cosmosdb_mongo.cosmosdb_mongo_collection_id
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
