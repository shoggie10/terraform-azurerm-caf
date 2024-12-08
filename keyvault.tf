
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
resource "azurerm_cosmosdb_table" "this" {
  name                = var.table_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.table_throughput != null ? var.table_throughput : null

  autoscale_settings {
    max_throughput = var.table_max_throughput
  }
}





# variables.tf
----------
variable "table_name" {
  description = "The name of the Cosmos DB Table."
  type        = string
}

variable "table_throughput" {
  description = "The throughput for the table. If null, the table will be autoscaled."
  type        = number
  default     = null
}

variable "table_max_throughput" {
  description = "The maximum throughput to use for autoscaling the table."
  type        = number
  default     = 400
}

variable "table_throughput" {
  description = "The throughput for the table. If null, the table will be autoscaled."
  type        = number
  default     = null
  validation {
    condition     = var.table_throughput >= 400
    error_message = "Table throughput must be a positive number greater than or equal to 400."
  }
}




# locals.tf
------------
locals {
  table_throughput = var.table_throughput != null ? var.table_throughput : var.table_max_throughput
}





# outputs.tf
----------
output "cosmosdb_table_id" {
  description = "The ID of the Cosmos DB Table."
  value       = azurerm_cosmosdb_table.this.id
}





# examples.tf
-----------
module "cosmosdb_table" {
  source            = "./path/to/your/module"
  table_name        = "example-table"
  table_throughput  = 1000
  table_max_throughput = 4000
}

output "cosmosdb_table_id" {
  value = module.cosmosdb_table.cosmosdb_table_id
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
