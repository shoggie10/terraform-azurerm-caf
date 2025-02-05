module "lb" {
  source   = "./modules/networking/lb"
  for_each = local.networking.lb

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group      = local.combined_objects_resource_groups
    virtual_network     = local.combined_objects_networking
    public_ip_addresses = local.combined_objects_public_ip_addresses
  }
}
output "lb" {
  value = module.lb
}


=================||
##[error]No agent found in pool sonarqube which satisfies the specified demands: java, Agent.Version -gtVersion 3.218.0
Pool: sonarqube
Started: Just now
Duration: 1m 48s

Job preparation parameters




=========




======||===

-----\\---





-----------------------------------------------------

## Required Module Specific Variables

variable "consistency_level" {
  description = "(Required) The Consistency Level to use for this CosmosDB Account. Valid values are (BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix)"
  type        = string
  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "Valid values for cosmosdb kind are (BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix)."
  }
}

variable "resource_group_name" {
  description = "(Required) Name of the resource group where the cosmosdb belongs."
  type        = string
}

## Optional Module Specific Variables

variable "additional_ip_addresses" {
  description = "(Optional) One or more IP Addresses, or CIDR Blocks which should be able to access CosmosDb. Additional Ip's can be whitelisted when 'private endpoint is not enabled'"
  type        = list(any)
  default     = []
}

variable "additional_subnet_ids" {
  description = "(Optional) Subnet/s to be allowed in the firewall to access CosmosDb"
  type        = list(any)
  default     = []
}

variable "allowed_origins" {
  description = <<EOT
  (Optional) Configures the allowed origins for this Cosmos DB account in CORS Feature:
  A list of origin domains that will be allowed by CORS.
  EOT
  type        = list(string)
  default     = []
}

variable "backup_type" {
  description = "(Optional) The type of the backup. Possible values are Continuous and Periodic. Defaults to Periodic."
  type        = string
  default     = "Periodic"
}

variable "capabilities" {
  description = <<EOT
  (Optional) Configures the capabilities to enable for this Cosmos DB account:
  Possible values are
  AllowSelfServeUpgradeToMongo36, DisableRateLimitingResponses,
  EnableAggregationPipeline, EnableCassandra, EnableGremlin,EnableMongo, EnableTable, EnableServerless,
  MongoDBv3.4 and mongoEnableDocLevelTTL.
  EOT
  type        = list(string)
  default     = []
}

variable "database_settings" {
  description = "(Optional) Supported API for the databases in the account and a list of databases to provision. Allowed values of API type are Sql, Cassandra, MongoDB, Gremlin, Table. If 'use_autoscale' is set, 'throughput' becomes 'max_throughput' with a minimum value of 1000."
  type = object({
    api_type = string
    databases = list(object({
      name          = string
      throughput    = number
      use_autoscale = bool #If set, throughput will become max_throughput
    }))
  })
  default = {
    api_type  = "Sql"
    databases = []
  }
  validation {
    condition     = contains(["Sql", "Cassandra", "MongoDB", "Gremlin", "Table"], var.database_settings.api_type)
    error_message = "Valid values for database API type are (Sql, Cassandra, MongoDB, Gremlin and Table)."
  }
}

variable "database_throughput" {
  description = "(Optional) RU throughput value for the selected database."
  type        = number
  default     = 400
}

variable "enable_automatic_failover" {
  description = "(Optional) Enable automatic failover for this Cosmos DB account. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_automatic_failover))
    error_message = "Valid values are true, false."
  }
}

variable "enable_diagnostics" {
  description = "(Optional) Enable Cosmosdb diagnostic setting. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_diagnostics))
    error_message = "Valid values are true, false."
  }
}

variable "enable_multiple_write_locations" {
  description = "(Optional) Enable multiple write locations for this Cosmos DB account. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_multiple_write_locations))
    error_message = "Valid values are true, false."
  }
}

variable "enable_private_endpoint" {
  description = "(Optional) Private Endpoint requirement. Valid values are (true, false). "
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_private_endpoint))
    error_message = "Valid values are true, false."
  }
}

variable "enable_replication" {
  description = "(Optional) Enable replication of this Cosmos DB account to a secondary location. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_replication))
    error_message = "Valid values are true, false."
  }
}

variable "failover_location" {
  description = "(Optional) The name of the Azure region to host replicated data. Valid values are (eastus2, centralus)."
  type        = string
  default     = ""
  validation {
    condition     = contains(["", "eastus2", "centralus"], var.failover_location)
    error_message = "Valid values for failover_location are (eastus2 and centralus)."
  }
}

variable "failover_priority" {
  description = "(Optional) The failover priority of the region. A failover priority of 0 indicates a write region."
  type        = string
  default     = "0"
}

variable "index" {
  description = "(Optional) cosmosdb unique index (ex: 01,02...etc)"
  type        = string
  default     = "01"
}

variable "interval_in_minutes" {
  description = "(Optional) The interval in minutes between two backups. This is configurable only when type is Periodic. Possible values are between 60 and 1440."
  type        = number
  default     = 60
  validation {
    condition     = var.interval_in_minutes >= 60 && var.interval_in_minutes <= 1440 && floor(var.interval_in_minutes) == var.interval_in_minutes
    error_message = "Accepted values in between (minutes): 60 - 1440."
  }
}

variable "is_test_run" {
  description = "(Optional) Is this a test run? Defaults to false. Only set to true to use in a test harness to disable certain networking features."
  type        = bool
  default     = false
}

variable "kind" {
  description = "(Optional) Specifies the Kind of CosmosDB to create - possible values are 'GlobalDocumentDB' and 'MongoDB'."
  type        = string
  default     = "GlobalDocumentDB"
  validation {
    condition     = contains(["MongoDB", "GlobalDocumentDB"], var.kind)
    error_message = "Valid values for cosmosdb kind are (GlobalDocumentDB or MongoDB)."
  }
}

variable "local_authentication_disabled" {
  description = <<EOT
  (Optional) Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication.
  Defaults to false. Can be set only when using the SQL API.
  Valid values are (true, false).
  EOT
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.local_authentication_disabled))
    error_message = "Valid values are true, false."
  }
}

variable "max_interval_in_seconds" {
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day)."
  type        = string
  default     = "5"
}

variable "max_staleness_prefix" {
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647."
  type        = string
  default     = "10"
}

variable "pe_subnet_id_primary" {
  description = <<EOT
  (Optional) Private endpoint Subnet id, required when Private_Endpoint is enabled
  Subnet_ID usage: "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}"
  EOT
  default     = ""
}

variable "pe_subnet_id_secondary" {
  description = <<EOT
  (Optional) Private endpoint Subnet id, required when Private_Endpoint is enabled and replicating to a secondary region
  Subnet_ID usage: "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}"
  EOT
  default     = ""
}

variable "retention_days" {
  description = "(Optional) Cosmosdb retention daysl[Provide retention days if 'enable_diagnostics' is set to true]"
  default     = 7
}

variable "retention_in_hours" {
  description = "(Optional) The time in hours that each backup is retained. This is configurable only when type is Periodic. Possible values are between 8 and 720."
  type        = number
  default     = 8
  validation {
    condition     = var.retention_in_hours >= 8 && var.retention_in_hours <= 720 && floor(var.retention_in_hours) == var.retention_in_hours
    error_message = "Accepted values in between (hours): 8 - 720."
  }
}

variable "storage_redundancy" {
  description = "(Optional) The storage redundancy is used to indicate the type of backup residency. This is configurable only when type is Periodic. Possible values are Geo, Local and Zone."
  type        = string
  default     = "Local"
  validation {
    condition     = contains(["Geo", "Local", "Zone"], var.storage_redundancy)
    error_message = "Valid values for storage_redundancy are (Geo, Local and Zone)."
  }
}

variable "is_msdn_cosmosdb" {
  description = "Is this cosmos db to be used in an msdn subscription. Default is false."
  type        = bool
  default     = false
}

variable "dns_private_zone_rg" {
  type        = string
  description = "The resource group that the privatelink DNS zone record is in (Azure Private DNS)"
  default     = "dnsproxy-prd"
}

variable "is_virtual_network_filter_enabled" {
  description = "Is this cosmos db to be used in an msdn subscription. Default is false."
  type        = bool
  default     = true
}

variable "zone_redundant" {
  description = "(Optional) Should Zone Redundancy in the primary region be enabled?"
  type        = bool
  default     = false
}

variable "failover_zone_redundant" {
  description = "(Optional) Should Zone Redundancy in the failover region be enabled?"
  type        = bool
  default     = false
}

### ----
# Outputs
output "cosmosdb_id" {
  description = "ID of the deployed CosmosDB account"
  value       = azurerm_cosmosdb_account.db.id
}

output "cosmosdb_name" {
  description = "Name of the deployed CosmosDB account"
  value       = azurerm_cosmosdb_account.db.name
}

### locals
locals {
  cosmosdb_name = ""


}

------------------
module "cosmosdb_account" {
  source = "./modules/cosmosdb_account"

  location                         = "East US"
  resource_group_name              = "example-resource-group"
  cosmosdb_name                    = "example-cosmosdb"
  kind                             = "MongoDB"
  enable_private_endpoint          = false
  is_virtual_network_filter_enabled = false
  enable_automatic_failover        = true
  enable_multiple_write_locations = true
  key_vault_name                   = "example-keyvault"
  enable_systemassigned_identity   = true
  zone_redundant                   = true
  failover_location                = "West US"
  failover_zone_redundant          = false
  allowed_origins                  = ["https://example.com"]
  additional_subnet_ids            = []
  capabilities                     = ["EnableCassandra"]
  consistency_level                = "Session"
  max_interval_in_seconds          = 5
  max_staleness_prefix             = 10000
  backup_type                      = "Periodic"
  interval_in_minutes              = 30
  retention_in_hours               = 24
  storage_redundancy               = "GeoRedundant"
}




========================||========================
Gremlin API Example:
# Gremlin API Configuration Example

resource "azurerm_cosmosdb_gremlin_database" "gremlin_db" {
  name                = "gremlin-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_gremlin_graph" "gremlin_graph" {
  name                = "gremlin-graph"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_gremlin_database.gremlin_db.name

  index_policy {
    automatic      = true
    indexing_mode  = "consistent"
    included_paths = ["/*"]
    excluded_paths = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
--------------------------------------
Cassandra API Example
# Cassandra API Configuration Example

resource "azurerm_cosmosdb_cassandra_keyspace" "cassandra_keyspace" {
  name                = "cassandra-keyspace"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
}

resource "azurerm_cosmosdb_cassandra_table" "cassandra_table" {
  name                 = "cassandra-table"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  keyspace_name        = azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspace.name

  schema {
    partition_key {
      name = "id"
    }

    clustering_key {
      name     = "timestamp"
      order_by = "ASC"
    }

    columns {
      name = "id"
      type = "uuid"
    }

    columns {
      name = "timestamp"
      type = "timestamp"
    }

    columns {
      name = "value"
      type = "text"
    }
  }

  throughput = 400
}
---------------------------------
SQL API Example
# SQL API Configuration Example

resource "azurerm_cosmosdb_sql_database" "sql_db" {
  name                = "sql-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_sql_container" "sql_container" {
  name                 = "sql-container"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  database_name        = azurerm_cosmosdb_sql_database.sql_db.name
  partition_key_path   = "/id"
  throughput           = 400

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
-------------------------------------------------
MongoDB API Example
# MongoDB API Configuration Example

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "mongo-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_mongo_collection" "mongo_collection" {
  name                 = "mongo-collection"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  database_name        = azurerm_cosmosdb_mongo_database.mongo_db.name
  partition_key_path   = "/_id"
  throughput           = 400

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
---------------------------------------------
Table API Example
# Table API Configuration Example

resource "azurerm_cosmosdb_table" "table_db" {
  name                = "table-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_table_entity" "table_entity" {
  table_name          = azurerm_cosmosdb_table.table_db.name
  partition_key       = "partitionKey"
  row_key             = "rowKey"
  properties = {
    "property1" = "value1"
    "property2" = "value2"
  }
}
-----------------------------------------------
PostgreSQL API Example
# PostgreSQL API Configuration Example

resource "azurerm_cosmosdb_postgresql_cluster" "postgresql_cluster" {
  name                = "postgresql-cluster"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  administrator_login = var.admin_login
  administrator_password = var.admin_password
  version             = "13"
  sku_name            = "GP_Gen5_2"
  storage_mb          = 5120
  backup_retention_days = 30
  geo_redundant_backup_enabled = true
  tags                = var.tags
}

resource "azurerm_cosmosdb_postgresql_database" "postgresql_db" {
  name                = "postgresql-database"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_postgresql_cluster.postgresql_cluster.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
  throughput          = 400
}

resource "azurerm_cosmosdb_postgresql_table" "postgresql_table" {
  name                = "postgresql-table"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_postgresql_cluster.postgresql_cluster.name
  database_name       = azurerm_cosmosdb_postgresql_database.postgresql_db.name
  schema              = "public"
  columns = [
    { name = "id", type = "SERIAL PRIMARY KEY" },
    { name = "name", type = "VARCHAR(100)" },
    { name = "created_at", type = "TIMESTAMP" }
  ]
  throughput           = 400
}




======================||==========================
========================||========================
# main.tf
---
resource "azurerm_cosmosdb_gremlin_database" "this" {
  name                = var.gremlin_database_name
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = var.database_throughput

  tags = var.tags
}

resource "azurerm_cosmosdb_gremlin_graph" "this" {
  name                = var.gremlin_graph_name
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_gremlin_database.this.name

  index_policy {
    automatic      = true
    indexing_mode  = "consistent"
    included_paths = ["/*"]
    excluded_paths = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}

module "rbac" {
  source = "app.terraform.io/xxxx/common/azure"

  for_each = var.role_assignments

  resource_id   = azurerm_cosmosdb_gremlin_graph.this.id
  resource_name = azurerm_cosmosdb_gremlin_graph.this.name

  role_based_permissions = {
    assignment = {
      role_definition_id_or_name = each.value.role_definition_id_or_name
      principal_id               = each.value.principal_id
    }
  }
  wait_for_rbac = false
}



---
  dynamic "autoscale_settings" {
    for_each = var.enable_autoscale ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }


###=======================================
# globals.tf
---
data "azurerm_client_config" "current" {}

data "azurerm_cosmosdb_account" "this" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name
}





###=======================================
# variables.tf
---
variable "gremlin_database_name" {
  description = "Name of the Gremlin database to create"
  type        = string
}

variable "gremlin_graph_name" {
  description = "Name of the Gremlin graph to create"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group the Cosmos DB account resides in"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "Name of the Cosmos DB account"
  type        = string
}

variable "database_throughput" {
  description = "Throughput for the Gremlin database (e.g., RU/s)"
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
DESCRIPTION
  nullable    = false
}

variable "terraform_module" {
  description = "Used to inform of a parent module"
  type        = string
  default     = ""
}




---
Updated variables.tf (Autoscale Throughput):

variable "enable_autoscale" {
  description = "Flag to enable autoscale throughput"
  type        = bool
  default     = false
}

variable "max_throughput" {
  description = "Maximum throughput for autoscale settings"
  type        = number
  default     = null
}





###=======================================
# outputs.tf
---
output "gremlin_database_id" {
  value       = azurerm_cosmosdb_gremlin_database.this.id
  description = "The ID of the Gremlin database"
}

output "gremlin_graph_id" {
  value       = azurerm_cosmosdb_gremlin_graph.this.id
  description = "The ID of the Gremlin graph"
}




---
### Output Additional Attributes: Include outputs for additional resource details, such as schema and throughput.
output "cassandra_keyspace_throughput" {
  value       = azurerm_cosmosdb_cassandra_keyspace.this.throughput
  description = "The throughput of the Cassandra keyspace"
}

output "cassandra_table_schema" {
  value       = azurerm_cosmosdb_cassandra_table.this.schema
  description = "The schema of the Cassandra table"
}




=====
### Validation Blocks: Add validation blocks for critical variables to prevent misconfigurations.

### Example for partition_key_name.:
variable "partition_key_name" {
  description = "The name of the partition key column"
  type        = string
  validation {
    condition     = contains(var.columns[*].name, var.partition_key_name)
    error_message = "Partition key name must match one of the defined column names."
  }
}



### Example for variable partition_key_name.: 
variable "partition_key_type" {
  description = "The data type of the partition key column (e.g., 'ascii', 'text', 'int')"
  type        = string
  validation {
    condition     = contains(["ascii", "text", "int", "uuid", "timestamp"], var.partition_key_type)
    error_message = "Partition key type must be a valid Cassandra type (e.g., 'ascii', 'text', 'int')."
  }
}




╵=============================||=================================================
The cosmosdb_cassandra_database module is designed specifically to create and manage Cosmos DB Cassandra API databases. This module adheres to the new design principles and integrates seamlessly with the foundational module cosmosdb_account_common, which serves as a flexible and reusable base for implementing Cosmos DB accounts for Cassandra and other API databases.

Key Features:
Simplifies the deployment and configuration of Cassandra API databases within a Cosmos DB account.
Leverages cosmosdb_account_common for centralized configurations, including consistency policies, geo-replication, network security, and tagging.
Promotes modularity, enabling independent scaling and management of Cassandra API databases.

Integration:
This module is designed to operate in conjunction with the cosmosdb_account_common foundational module. Ensure the foundational module is deployed and configured to establish consistent settings across all API databases while maintaining the flexibility to tailor Cassandra-specific requirements.

Planned updates include support for advanced features such as dynamic throughput scaling, enhanced diagnostic integration, and additional security configurations, aligned with improvements in the foundational module.

--------------------------------------------------
The cosmosdb_postgresql_database module is designed specifically to create and manage Cosmos DB PostgreSQL API databases. This module aligns with the new design approach and integrates seamlessly with the foundational module cosmosdb_account_common, which serves as a flexible and reusable base for implementing Cosmos DB accounts for PostgreSQL and other API databases.

Key Features:
Simplifies the deployment and management of PostgreSQL API databases within a Cosmos DB account.
Utilizes cosmosdb_account_common for shared configurations such as consistency policies, geo-replication, network security, and tagging.
Ensures modularity, enabling independent configuration and scaling of PostgreSQL API databases.

Integration:
This module is intended to work alongside the cosmosdb_account_common foundational module. Ensure the foundational module is deployed and properly configured to maintain consistent account-level settings while providing flexibility for PostgreSQL-specific database needs.

Future enhancements will include advanced features such as dynamic throughput scaling, enhanced diagnostic settings, and additional security measures, in line with updates to the foundational module.
========
artifact feeds also use this RBAC role permission but with different, and more, roles.

the scope value here determines what type of resource we are applying these permissions for
 

module "lb_backend_address_pool" {
  source   = "./modules/networking/lb_backend_address_pool"
  for_each = local.networking.lb_backend_address_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value


  remote_objects = {
    lb = local.combined_objects_lb
  }
}
output "lb_backend_address_pool" {
  value = module.lb_backend_address_pool
}

module "lb_backend_address_pool_address" {
  source   = "./modules/networking/lb_backend_address_pool_address"
  for_each = local.networking.lb_backend_address_pool_address

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    virtual_network         = local.combined_objects_networking
    lb_backend_address_pool = local.combined_objects_lb_backend_address_pool
  }
}
output "lb_backend_address_pool_address" {
  value = module.lb_backend_address_pool_address
}

module "lb_nat_pool" {
  source   = "./modules/networking/lb_nat_pool"
  for_each = local.networking.lb_nat_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_nat_pool" {
  value = module.lb_nat_pool
}
module "lb_nat_rule" {
  source   = "./modules/networking/lb_nat_rule"
  for_each = local.networking.lb_nat_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_nat_rule" {
  value = module.lb_nat_rule
}

module "lb_outbound_rule" {
  source   = "./modules/networking/lb_outbound_rule"
  for_each = local.networking.lb_outbound_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group          = local.combined_objects_resource_groups
    lb                      = local.combined_objects_lb
    lb_backend_address_pool = local.combined_objects_lb_backend_address_pool
  }
}
output "lb_outbound_rule" {
  value = module.lb_outbound_rule
}

module "lb_probe" {
  source   = "./modules/networking/lb_probe"
  for_each = local.networking.lb_probe

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_probe" {
  value = module.lb_probe
}
module "lb_rule" {
  source   = "./modules/networking/lb_rule"
  for_each = local.networking.lb_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  backend_address_pool_ids = can(each.value.backend_address_pool_ids) || can(each.value.backend_address_pool) == false ? try(each.value.backend_address_pool_ids, null) : [
    for k, v in each.value.backend_address_pool : local.combined_objects_lb_backend_address_pool[try(v.lz_key, local.client_config.landingzone_key)][v.key].id
  ]
  probe_id = can(each.value.probe_id) || can(each.value.probe.key) == false ? try(each.value.probe_id, null) : local.combined_objects_lb_probe[try(each.value.probe.lz_key, local.client_config.landingzone_key)][each.value.probe.key].id

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_rule" {
  value = module.lb_rule
}
