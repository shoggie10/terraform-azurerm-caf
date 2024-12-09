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
-----------------------------------------------------

resource "azurerm_cosmosdb_account" "db" {
  name                               = local.cosmosdb_name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  offer_type                         = "Standard"
  kind                               = var.kind
  public_network_access_enabled      = !var.enable_private_endpoint
  is_virtual_network_filter_enabled  = var.is_virtual_network_filter_enabled
  access_key_metadata_writes_enabled = false

  ip_range_filter = var.enable_private_endpoint || var.is_msdn_cosmosdb 
  enable_automatic_failover       = var.enable_automatic_failover
  enable_multiple_write_locations = var.enable_multiple_write_locations
  

  key_vault_key_id                = var.key_vault_name != "" ? data.azurerm_key_vault_key.this[0].versionless_id : null
  # When referencing an azurerm_key_vault_key resource, use versionless_id instead of id

  dynamic "identity" {
    for_each = var.enable_systemassigned_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.zone_redundant
  }

  geo_location {
    location          = var.enable_replication ? var.failover_location : var.location
    failover_priority = var.enable_replication ? 1 : 0
    zone_redundant    = var.failover_zone_redundant
  }



  dynamic "cors_rule" {
    for_each = toset(var.allowed_origins)
    content {
      allowed_headers    = ["*"]
      allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
      allowed_origins    = cors_rule.key
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  dynamic "virtual_network_rule" {
    for_each = var.enable_private_endpoint || var.is_msdn_cosmosdb || var.is_test_run ? [] : (var.additional_subnet_ids != [] 
    content {
      id                                   = virtual_network_rule.value
      ignore_missing_vnet_service_endpoint = false
    }
  }


  dynamic "capabilities" {
    for_each = toset(var.capabilities)
    content {
      name = capabilities.key
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  backup {
    type                = var.backup_type
    interval_in_minutes = var.backup_type == "Periodic" ? var.interval_in_minutes : null
    retention_in_hours  = var.backup_type == "Periodic" ? var.retention_in_hours : null
    storage_redundancy  = var.backup_type == "Periodic" ? var.storage_redundancy : null
  }

  tags = module.shared_vars.common_tags
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

╷
│ Error: checking for presence of existing Key "cdbwaynetechhubdev707857-encryption" (Key Vault "https://kv-0000-cosmosd-dev-400.vault.azure.net/"): keyvault.BaseClient#GetKey: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="Forbidden" Message="Caller is not authorized to perform action on resource.\r\nIf role assignments, deny assignments or role definitions were changed recently, please observe propagation time.\r\nCaller: appid=04b07795-8ddb-461a-bbee-02f9e1bf7b46;oid=730ce96a-7db7-4204-9611-4851956b3076;iss=https://sts.windows.net/e7066c90-b459-44c5-91f1-3581f3d1f082/\r\nAction: 'Microsoft.KeyVault/vaults/keys/read'\r\nResource: '/subscriptions/b987518f-1b04-4491-915c-e21dabc7f2d3/resourcegroups/wayne-tech-hub/providers/microsoft.keyvault/vaults/kv-0000-cosmosd-dev-400/keys/cdbwaynetechhubdev707857-encryption'\r\nAssignment: (not found)\r\nDenyAssignmentId: null\r\nDecisionReason: null \r\nVault: kv-0000-cosmosd-dev-400;location=eastus\r\n" InnerError={"code":"ForbiddenByRbac"}
│ 
│   with module.this.module.key_vault_key.azurerm_key_vault_key.this,
│   on .terraform/modules/this.key_vault_key/main.tf line 1, in resource "azurerm_key_vault_key" "this":
│    1: resource "azurerm_key_vault_key" "this" {

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
