
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
resource "azurerm_cosmosdb_gremlin_database" "this" {
  name                = var.db_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.db_throughput != null ? var.db_throughput : null

  autoscale_settings {
    max_throughput = var.db_max_throughput
  }
}

resource "azurerm_cosmosdb_gremlin_graph" "this" {
  name                = var.graph_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = var.db_name
  throughput          = var.graph_throughput != null ? var.graph_throughput : null
  analytical_storage_ttl = var.analytical_storage_ttl != null ? var.analytical_storage_ttl : null


  indexing_policy {
    indexing_mode = "Consistent"
    included_path {
      path = "/*"
    }
  }
  depends_on = [
    azurerm_cosmosdb_gremlin_database.this
  ]
}





# variables.tf
----------
variable "db_name" {
  description = "The name of the Cosmos DB Gremlin database."
  type        = string
}

variable "db_throughput" {
  description = "The throughput for the database. If null, the database will be autoscaled."
  type        = number
  default     = null
}

variable "db_max_throughput" {
  description = "The maximum throughput for autoscaling the database."
  type        = number
  default     = 400
}

variable "graph_name" {
  description = "The name of the Cosmos DB Gremlin graph."
  type        = string
}

variable "db_throughput" {
  description = "The throughput for the database. If null, the database will be autoscaled."
  type        = number
  default     = null
  validation {
    condition     = var.db_throughput >= 400 || var.db_throughput == null
    error_message = "Throughput must be greater than or equal to 400 if provided."
  }
}


variable "graph_max_throughput" {
  description = "The maximum throughput to use for autoscaling the graph."
  type        = number
  default     = 400
}

variable "analytical_storage_ttl" {
  description = "The TTL for analytical storage."
  type        = number
  default     = null
}


# locals.tf
------------
locals {
  database_throughput = var.db_throughput != null ? var.db_throughput : var.db_max_throughput
  graph_throughput = var.graph_throughput != null ? var.graph_throughput : var.graph_max_throughput
}




# outputs.tf
----------
output "cosmosdb_gremlin_database_id" {
  description = "The ID of the Cosmos DB Gremlin database."
  value       = azurerm_cosmosdb_gremlin_database.this.id
}

output "cosmosdb_gremlin_graph_id" {
  description = "The ID of the Cosmos DB Gremlin graph."
  value       = azurerm_cosmosdb_gremlin_graph.this.id
}




# examples.tf
-----------
module "cosmosdb_gremlin" {
  source               = "./path/to/your/module"
  db_name              = "example-gremlin-database"
  db_throughput        = 1000
  db_max_throughput    = 4000
  graph_name           = "example-graph"
  graph_throughput     = 500
  graph_max_throughput = 2000
  analytical_storage_ttl = 3600
}

output "cosmosdb_gremlin_database_id" {
  value = module.cosmosdb_gremlin.cosmosdb_gremlin_database_id
}

output "cosmosdb_gremlin_graph_id" {
  value = module.cosmosdb_gremlin.cosmosdb_gremlin_graph_id
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
