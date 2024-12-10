
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
resource "azurerm_cosmosdb_postgresql_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  location            = var.location
  administrator_login = var.administrator_login
  administrator_password = var.administrator_password
  sku_name            = var.sku_name
  capacity            = var.capacity
  backup_retention    = var.backup_retention
  geo_redundancy_enabled = var.geo_redundancy_enabled

  tags = var.tags
}






# variables.tf
----------
variable "cluster_name" {
  description = "The name of the Cosmos DB PostgreSQL cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the PostgreSQL cluster should be located."
  type        = string
}

variable "administrator_login" {
  description = "The administrator login for the PostgreSQL cluster."
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL cluster."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL cluster."
  type        = string
}

variable "capacity" {
  description = "The capacity for the PostgreSQL cluster."
  type        = number
}

variable "backup_retention" {
  description = "The backup retention period in days for the PostgreSQL cluster."
  type        = number
}

variable "geo_redundancy_enabled" {
  description = "Whether geo-redundancy is enabled for the PostgreSQL cluster."
  type        = bool
}

variable "tags" {
  description = "Tags to associate with the PostgreSQL cluster."
  type        = map(string)
  default     = {}
}

variable "backup_retention" {
  description = "The backup retention period in days for the PostgreSQL cluster."
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention >= 7
    error_message = "Backup retention should be at least 7 days."
  }
}

variable "geo_redundancy_enabled" {
  description = "Whether geo-redundancy is enabled for the PostgreSQL cluster."
  type        = bool
  default     = false
}




# locals.tf
------------
locals {
  backup_retention = var.backup_retention != null ? var.backup_retention : 7
}





# outputs.tf
----------
output "cosmosdb_postgresql_cluster_id" {
  description = "The ID of the Cosmos DB PostgreSQL cluster."
  value       = azurerm_cosmosdb_postgresql_cluster.this.id
}

output "cosmosdb_postgresql_cluster_name" {
  description = "The name of the Cosmos DB PostgreSQL cluster."
  value       = azurerm_cosmosdb_postgresql_cluster.this.name
}





# examples.tf
-----------
module "cosmosdb_postgresql" {
  source                  = "./path/to/your/module"
  cluster_name            = "example-postgresql-cluster"
  location                = "East US"
  administrator_login     = "adminuser"
  administrator_password  = "adminpassword"
  sku_name                = "Standard_B1ms"
  capacity                = 2
  backup_retention        = 7
  geo_redundancy_enabled  = true
  tags                    = {
    environment = "production"
  }
}

output "cosmosdb_postgresql_cluster_id" {
  value = module.cosmosdb_postgresql.cosmosdb_postgresql_cluster_id
}

output "cosmosdb_postgresql_cluster_name" {
  value = module.cosmosdb_postgresql.cosmosdb_postgresql_cluster_name
}








===========||=========
Comments for cosmosdb_sql_database Module

The cosmosdb_sql_database module is designed specifically to create and manage Cosmos DB SQL API databases. This module is intended to work in conjunction with the foundational module cosmosdb_account, which serves as a flexible and reusable base for implementing Cosmos DB accounts.

Key Features:
Simplifies the deployment and management of SQL API databases within a Cosmos DB account.
Ensures modularity by leveraging cosmosdb_account for shared configurations like consistency policies, network security, and tagging.
Supports independent configuration and scaling for SQL API databases without impacting other API types.
Integration:
To use this module, ensure that the cosmosdb_account module is deployed and properly configured as the base resource. This modular design allows for flexibility and scalability, enabling seamless integration of additional API types in the future.

This module will evolve to support advanced settings like throughput scaling and integration with diagnostic settings once the core functionality is validated.

----------------------------
The cosmosdb_mongo_database module is designed specifically to create and manage Cosmos DB MongoDB API databases. This module is intended to work seamlessly with the foundational module cosmosdb_account, which serves as a flexible and reusable base for implementing Cosmos DB accounts.

Key Features:
Simplifies the deployment and management of MongoDB API databases within a Cosmos DB account.
Leverages the cosmosdb_account module for shared configurations such as account-level policies, geo-replication, and network security.
Enables independent management of MongoDB API databases, ensuring modularity and ease of scaling.
Integration:
This module requires the cosmosdb_account module to be deployed and configured as the foundational resource. The modular approach ensures flexibility for adding or modifying other API types independently while maintaining a consistent base configuration.

Future updates will include support for advanced features like throughput scaling, diagnostic settings, and enhanced security configurations once the core functionality has been confirmed.














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
