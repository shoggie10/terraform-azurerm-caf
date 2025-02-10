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
https://us05web.zoom.us/j/86526167418?pwd=eugwcO1uniIUdwitbn3ActMoO5CCjG.1




=========




======||===

-----\\---





-----------------------------------------------------

## examples
provider "azurerm" {
  #4.0+ version of AzureRM Provider requires a subscription ID  
  subscription_id = "b987518f-1b04-4491-915c-e21dabc7f2d3"
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

data "azurerm_cosmosdb_account" "this" {
  name                = "cdbwaynetechhubdev175368"
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azuread_user" "this" {
  user_principal_name = "salonge@bokf.com"
}



module "this" {
  source = "../" 


  mongo_database_name   = "mongo_database1"
  resource_group_name   = "wayne-tech-hub"
  cosmosdb_account_name = data.azurerm_cosmosdb_account.this.name
  mongo_collection_name     = "wayne-tech-hub-mongo-collection"


  db_throughput             = 400
  db_max_throughput         = 1000
  collection_throughput     = 400
  collection_max_throughput = 1000
  index_keys                = ["_id", "email"]
  index_unique              = true

}

======================================
## .gitlab-ci.yml
include:
  - project: bokf/templates/gitlab
    file: terraform_module/0.1.0.yml
======================================
# .terraform-docs.yml
version: "=0.17.0"

formatter: markdown table

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

  hide-all: false # deprecated in v0.13.0, removed in v0.15.0
  show-all: true # deprecated in v0.13.0, removed in v0.15.0

content: |-
  # terraform--cosmosdb-mongo-database
  description goes here
  {{ .Requirements }}

  ## Usage Example
  ```hcl
  {{ include "examples/main.tf" }}
  ```

  {{ .Providers }}
  {{ .Modules }}
  {{ .Resources }}
  {{ .Inputs }}
  {{ .Outputs }}

output:
  file: "README.md"
  mode: replace
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  html: true
  indent: 2
  required: true
  sensitive: true
  type: true
==================||=========
# CHANGELOG.md


=============================
# CODEOWNERS

=============================
# GETTING_STARTED.md

# Getting Started

This project template contains all the necessary files to easily get started with building a Terraform Module.

First, read through the module best practices from Hashicorp:

* [Module Structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure)
* [Publish](https://www.terraform.io/docs/cloud/registry/publish.html)

Next, you'll need to update the following files and sections with your module.

1. __`versions.tf`__:
   1. If you need to restrict usage of this module to specific provider or terraform versions, add the constraints here
   2. Remove the example code
2. __`globals.tf`__:
   1. Add references to other deployments (data blocks) and/or local variables that will be helpful in step 4
   2. Remove the example code
3. __`variables.tf`__:
   1. Create input variables that can/need to be passed into this module, you will reference these in step 4
   2. Remove the example code
4. __`main.tf`__:
   1. Create your main code here, which will manage other resources and/or module calls
      NOTE: Instead of placing in the main.tf file, similar to a Terraform Application, you can create individual .tf files for multiple resources to simplify future changes
   2. Remove the example code
5. __`outputs.tf`__:
   1. Create any output values that should be made available to the project/module calling this module
   2. Remove the example code
6. __`README.md`__:
   1. Follow the instructions in [this file](./TERRAFORM_DOCS_INSTRUCTIONS.md).
7. __`examples`__:
   1. Create a directory for each example/test against this module. It is best practice to cover all "logic" in the module (i.e. if you have a conditional statement, there should be a example for each condition)
   2. Remove the example_a directory & file
8. __`CHANGELOG.md`__:
   1. Create a new change log entry (see [Change Log](#change-log) section)
9. __`CODEOWNERS`__:
   1. Remove the example code
   2. Create entries and/or sections for the files, directories, or patterns and the groups that are required for approval during a Merge Request (MR). See [GitLab Docs](https://docs.gitlab.com/ee/user/project/code_owners.html) for more information and syntax

## Directory Structure

The following displays the directory structure of this template and the purpose for specific files/directories 

      .
      ├── .vscode                      # Settings for Visual Studio Code
      ├── examples                     # Directory containing example module usage/calls for testing and user onboarding
         └── <name>                    # Sub-directory for the example name (i.e. s3-standard, s3-lifecycle)
            └── main.tf                # Example terraform call to the module
      ├── .editorconfig                # File to help with editor differences by OS
      ├── .gitignore                   # Files/Directories to ignore for Git Version Control
      ├── CHANGELOG.md                 # Log of all changes grouped by version
      ├── CODEOWNERS                   # File containing directories/files and specific users or groups that must approve
      ├── README.md                    # Main repo README file
      ├── globals.tf                   # Contains local variables and data blocks for reference across the module
      ├── main.tf                      # Main module code goes here (i.e. resource aws_s3_bucket)
      ├── outputs.tf                   # Variables to provide as output (accessible to the calling project/module)
      ├── variables.tf                 # Input variables to provide to the module
      └── versions.tf                  # Constraints for provider/resource versions (i.e. AWS provider ~> 3.0)

## Change Log

Terraform uses semantic versioning (`<major>.<minor>.<patch>`) and relies on version control software (VCS) tags to identify a new version to publish.

A CHANGELOG file tracks all the changes by version in friendly format, with the format of:

```
   ## Unreleased
      - <Change Type>
         1. <Description>
         2. <Description>

   ## Version ##.##.## - MON DD, YYYY
      - <Change Type>
         1. <Description>
               - Module(s): <module>, <module>
         2. <Description>
               - Module(s): <module>, <module>
```

Where the following placeholders are used as:

| Type         | Description                                                                    |
|--------------|--------------------------------------------------------------------------------|
| type         | Type of change, with acceptable values of <br />* **Added**: New features <br />* **Changed**: Updates to existing features <br />* **Deprecated**: Soon-to-be removed features <br />* **Removed**: Now removed features <br />* **Fixed**: Bug fixes <br />* **Security**: Vulnerability fixes                                           |
| module       | List of file(s) the change applies to                                          |
| description  | Description of the change made                                                 |

Changes are displayed in descending order (most recent first), with an UNRELEASED section at the very top for changes that are pending.
==================================
# globals.tf
data "azurerm_client_config" "current" {}

data "azurerm_cosmosdb_account" "this" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name
}

locals {
  database_throughput   = var.db_throughput != null ? var.db_throughput : var.db_max_throughput
  collection_throughput = var.collection_throughput != null ? var.collection_throughput : var.collection_max_throughput
}

==================================
# main.tf

locals {
  # These are the various naming standards
  tfModule          = "Example"                                                                                       ## This should be the service name please update without fail and do not remove these two definitions.
  tfModule_extended = var.terraform_module != "" ? join(" ", [var.terraform_module, local.tfModule]) : local.tfModule ## This is to send multiple tags if the main module have submodule calls.
}

resource "azurerm_cosmosdb_mongo_database" "this" {
  name                = var.mongo_database_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  resource_group_name = var.resource_group_name
  throughput          = var.db_throughput != null ? null : var.db_max_throughput

  autoscale_settings {
    max_throughput = var.db_max_throughput
  }
}

resource "azurerm_cosmosdb_mongo_collection" "this" {
  name                   = var.mongo_collection_name
  resource_group_name    = var.resource_group_name
  account_name           = data.azurerm_cosmosdb_account.this.name
  database_name          = azurerm_cosmosdb_mongo_database.this.name
  shard_key              = var.shard_key
  throughput             = var.collection_throughput != null ? null : var.collection_max_throughput
  analytical_storage_ttl = var.analytical_storage_ttl != null ? var.analytical_storage_ttl : null

  index {
    keys   = var.index_keys
    unique = var.index_unique != null ? var.index_unique : false
  }

}

module "rbac" {
  source = "app.terraform.io/bokf/common/azure"

  for_each = var.role_assignments

  resource_id   = azurerm_cosmosdb_mongo_collection.this.id
  resource_name = azurerm_cosmosdb_mongo_collection.this.name

  role_based_permissions = {
    assignment = {
      role_definition_id_or_name = each.value.role_definition_id_or_name
      principal_id               = each.value.principal_id
    }
  }
  wait_for_rbac = false
}


==================================
# outputs.tf
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

==================================
# README.md
<!-- BEGIN_TF_DOCS -->
# terraform-`<provider>`-`<name>`
`<description of module>`
## Requirements

| Name | Version |
|------|---------|
| terraform | `<Versions Supported>` |
| `<provider>` | `<Versions Supported>` |

## Usage Example

## Providers

| Name | Version |
|------|---------|
| `<provider>` | `<Versions Supported>` |
## Modules

| Name | Source | Version |
|------|--------|---------|
| `<provider>` | `<source>` | `<version>` |
## Resources

| Name | Type |
|------|------|
| `<resource>` | `<type>` |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `<variable>` | `<description>` | `<type>` | `<default value>` | `<Required Yes/No>` |

## Outputs

| Name | Description |
|------|-------------|
| `<output>` | `<description>` |
<!-- END_TF_DOCS -->

==================================
# TERRAFORM_DOCS_INSTRUCTIONS.md

# Using Terraform Docs
[__`terraform-docs`__](https://terraform-docs.io/) is a Homebrew package used to automatically generate README files for terraform modules.

## Install terraform-docs
1. From a terminal, run `brew install terraform-docs`.

## Create configuration file
1. In the content section of [this YAML file](./.terraform-docs.yml), add the module's name, a short description, and the relative path to the example file.
2. Remove TODO statements from YAML file.

## Run terraform-docs
1. From the root directory of the terraform module, run `terraform-docs -c .terraform-docs.yml .`. This will generate a README file for the terraform module containing all relevant information.
==================================
# variables.tf
variable "mongo_database_name" {
  description = "Name of the CosmosDB MongoDB database to create"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.mongo_database_name))
    error_message = "Database name must contain only alphanumeric characters, dashes, and underscores."
  }
}

variable "mongo_collection_name" {
  description = "Name of the CosmosDB MongoDB collection to create"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "The name of the CosmosDB account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "shard_key" {
  description = "The shard key for the MongoDB collection"
  type        = string
  default     = null
}

variable "indexes" {
  description = "List of indexes to create on the MongoDB collection"
  type = list(object({
    keys    = list(string)
    options = map(string)
  }))
  default = []
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
variable "collection_throughput" {
  description = "The throughput for the MongoDB collection (e.g., RU/s)"
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

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "terraform_module" {
  description = "Used to inform of a parent module"
  type        = string
  default     = ""
}

### 
variable "autoscale_throughput" {
  description = "Enable autoscale throughput for the database"
  type        = bool
  default     = false
}

variable "max_throughput" {
  description = "Maximum throughput for autoscale settings"
  type        = number
  default     = null
}


==================================
# versions.tf
## Please refer to version template document for setting this configuration.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }
  }
}

==================================
==================================
==================================
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
