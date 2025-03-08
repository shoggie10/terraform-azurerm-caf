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
====================||===========

https://us05web.zoom.us/j/85648268297?pwd=5fWiOrZv61Fw9VC9LYBbajOTzkGMxe.1





=================||


=====||====





=====||===







=========





======||===

-----\\---





-----------------------------------------------------

## examples
provider "azurerm" {
  #4.0+ version of AzureRM Provider requires a subscription ID  
  subscription_id = "b987518f-1b04-4491-915c-e21dabc7f2d3"    #"0b5a3199-58bb-40ef-bcce-76a53aa594c2"

  #resource_provider_registrations = "none"

  features {

  }
}

locals {
  tags = {
    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "confidential"
    managed_by          = "it_cloud"
    requested_by        = "me@email.com"
    cost_center         = "1234"
    source_code         = "https://gitlab.com/company/test"
    deployed_by         = "test-workspace"
    application_role    = ""
  }
}


data "azurerm_resource_group" "this" {
  name = "wayne-tech-hub"
}

# data "azurerm_cosmosdb_account" "this" {
#   name                = "cdbwaynetechhubdev259678"
#   resource_group_name = data.azurerm_resource_group.this.name
# }

data "azuread_user" "this" {
  user_principal_name = "salonge@bokf.com"   # "SXA7BU_PA@bokf.onmicrosoft.com"
}

module "this" {
  source                          = "../"


  #data_factory_name               = "adf-test-001"
  application_name = "datafactory1"
  resource_group_name             = "wayne-tech-hub"
  location                        = data.azurerm_resource_group.this.location
  tags = local.tags


  global_parameters = {
    "testbool" = {
      type  = "Bool"
      value = true
    }
  }

}







================================||
# customer-managed-key.tf



=======================================
======================================
## .gitlab-ci.yml


=======================================
======================================
# .terraform-docs.yml



=================================
==================||=========
# CHANGELOG.md


=============================
# CODEOWNERS

=============================
# GETTING_STARTED.md



=================================
==================================
# globals.tf
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "random_integer" "this" {
  min = "100"
  max = "999"
}

locals {
  data_factory_name  = "adf${var.application_name}${var.tags.environment}${random_integer.this.result}"
  tfModule          = "data-factory"                                                                                     ## This should be the service name please update without fail and do not remove these two definitions.
  tfModule_extended = var.terraform_module != "" ? join(" ", [var.terraform_module, local.tfModule]) : local.tfModule ## This is to send multiple tags if the main module have submodule calls.
  key_vault_name    = "kv-${var.tags.application_id}-${lower(substr(var.application_name, 0, 7))}-${var.tags.environment}-${random_integer.this.result}"
}







==================================
==================================
# main.tf
# Create Azure Data Factory
resource "azurerm_data_factory" "this" {
  name                             = local.data_factory_name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  managed_virtual_network_enabled  = var.managed_virtual_network_enabled
  public_network_enabled           = var.public_network_enabled
  customer_managed_key_id          = var.customer_managed_key_id
  customer_managed_key_identity_id = var.customer_managed_key_identity_id
  tags                             = module.tags.tags


  dynamic "github_configuration" {
    for_each = var.github_configuration != null ? [var.github_configuration] : []
    content {
      git_url         = github_configuration.value.git_url
      account_name    = github_configuration.value.account_name
      branch_name     = github_configuration.value.branch_name
      repository_name = github_configuration.value.repository_name
      root_folder     = github_configuration.value.root_folder
    }
  }

  dynamic "global_parameter" {
    for_each = var.global_parameters
    content {
      name  = global_parameter.key
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Optional Azure Integration Runtime
resource "azurerm_data_factory_integration_runtime_azure" "this" {
  for_each = var.azure_integration_runtime

  name                    = each.key
  data_factory_id         = azurerm_data_factory.this.id
  location                = var.location
  description             = each.value.description
  compute_type            = each.value.compute_type
  core_count              = each.value.core_count
  time_to_live_min        = each.value.time_to_live_min
  cleanup_enabled         = each.value.cleanup_enabled
  virtual_network_enabled = each.value.virtual_network_enabled
}




======||
# tags.tf
module "tags" {
  source  = "app.terraform.io/bokf/tag/cloud"
  version = "0.3.2"

  tags = var.tags
}
====||=
variables.encyption.tf


====||


=====||
variables.network.tf





==================================
==================================
# outputs.tf
output "id" {
  description = "The ID of the new Datafactory resource."
  value       = azurerm_data_factory.this.id
}

output "name" {
  description = "The name of the newly created Azure Data Factory"
  value       = azurerm_data_factory.this.name
}


output "global_paramaters" {
  description = "A map showing any created Global Parameters."
  value       = { for gp in azurerm_data_factory.this.global_parameter : gp.name => gp }
}



===================================
==================================
# README.md


==================================
==================================
# TERRAFORM_DOCS_INSTRUCTIONS.md


==================================
==================================
# variables.tf
# Required Input Standard Variables 
variable "application_name" {
  type        = string
  description = "The name of the resource."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}



variable "tags" {
  type        = map(string)
  description = <<-EOT
  Required BOKF tags are listed below with sample values. These values are validated by the underlying Tags module.

    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "confidential"
    managed_by          = "it_cloud"
    cost_center         = "1234"
    source_code         = "https://gitlab.com/company/test"
    deployed_by         = "test-workspace"
    application_role    = "app"

  EOT
}


variable "public_network_enabled" {
  type        = bool
  description = "(Optional) Is the Data Factory visible to the public network? Defaults to true"
  default     = true
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Is Managed Virtual Network enabled?"
  default     = true
}

variable "customer_managed_key_id" {
  type        = string
  description = "Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key (CMK) for double encryption. Required with user assigned identity."
  default     = null
}

variable "customer_managed_key_identity_id" {
  type        = string
  description = "Specifies the ID of the user assigned identity associated with the Customer Managed Key. Must be supplied if customer_managed_key_id is set."
  default     = null
}

variable "github_configuration" {
  description = "An input object to define the settings for connecting to GitHub. NOTE! You must log in to the Data Factory management UI to complete the authentication to the GitHub repository."
  type = object({
    git_url         = optional(string) # - OPTIONAL: Specifies the GitHub Enterprise host name. Defaults to "https://github.com"
    account_name    = optional(string) # - REQUIRED: Specifies the GitHub account name. Defaults to ''
    repository_name = optional(string) # - REQUIRED: Specifies the name of the git repository. 
    branch_name     = optional(string) # - OPTIONAL: Specifies the branch of the repository to get code from. Defaults to 'main'
    root_folder     = optional(string) # - OPTIONAL: Specifies the root folder within the repository. Defaults to '/' for top level.
  })
  default = null
}

variable "global_parameters" {
  type        = any
  description = "An input object to define a global parameter. Accepts multiple entries."
  default     = {}
}

variable "azure_integration_runtime" {
  type = map(object({
    description             = optional(string, "Azure Integrated Runtime")
    compute_type            = optional(string, "General")
    virtual_network_enabled = optional(string, true)
    core_count              = optional(number, 8)
    time_to_live_min        = optional(number, 0)
    cleanup_enabled         = optional(bool, true)
  }))
  description = <<EOF
  Map Object to define any Azure Integration Runtime nodes that required.
  key of each object is the name of a new node.
  configuration parameters within the object allow customisation.
  EXAMPLE:
  azure_integration_runtime = {
    az-ir-co-01 {
      "compute_type" .  = "ComputeOptimized"
      "cleanup_enabled" = true
      core_count        = 16
    },
    az-ir-gen-01 {},
    az-ir-gen-02 {},
  }

EOF
  default     = {}
}

variable "terraform_module" {
  description = "Used to inform of a parent module"
  type        = string
  default     = ""
}









==================================
==================================
# versions.tf
## Please refer to version template document for setting this configuration.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "< 5.0.0"
    }
  }
}



==================================
==================================
==================================
------------------







===========||===================
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
