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

variable "database_settings" {
  type = map(any)
  default = {
    "Cassandra" = {
      kind         = "GlobalDocumentDB"
      capabilities = ["EnableCassandra"]
    }
    "Gremlin" = {
      kind         = "GlobalDocumentDB"
      capabilities = ["EnableGremlin"]
    }
    "Table" = {
      kind         = "GlobalDocumentDB"
      capabilities = ["EnableTable"]
    }
    "PostgreSQL" = {
      kind         = "GlobalDocumentDB"
      capabilities = []
    }
  }
}



=================||
│ Error: creating Server Groupsv 2 (Subscription: "b987518f-1b04-4491-915c-e21dabc7f2d3"
│ Resource Group Name: "wayne-tech-hub"
│ Server Groupsv 2 Name: "postgresql2"): performing Create: unexpected status 400 (400 Bad Request) with error: bad_request: Node properties must be sent when node count is higher than 0.
│ 
│   with module.this.azurerm_cosmosdb_postgresql_cluster.this,
│   on ../main.tf line 11, in resource "azurerm_cosmosdb_postgresql_cluster" "this":
│   11: resource "azurerm_cosmosdb_postgresql_cluster" "this" {
│ 
│ creating Server Groupsv 2 (Subscription: "b987518f-1b04-4491-915c-e21dabc7f2d3"
│ Resource Group Name: "wayne-tech-hub"
│ Server Groupsv 2 Name: "postgresql2"): performing Create: unexpected status 400 (400 Bad Request) with error: bad_request:
│ Node properties must be sent when node count is higher than 0.



=====||===







=========





======||===

-----\\---





-----------------------------------------------------

## examples








================================||
# customer-managed-key.tf



#################
# Create the Key Vault




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






==================================
==================================
# main.tf



======||
# tags.tf

====||=
variables.encyption.tf


====||


=====||
variables.network.tf





==================================
==================================
# outputs.tf




===================================
==================================
# README.md


==================================
==================================
# TERRAFORM_DOCS_INSTRUCTIONS.md


==================================
==================================
# variables.tf







==================================
==================================
# versions.tf




==================================
==================================
==================================
------------------







===========||===================
module "cosmosdb_account" {




========================||========================
Gremlin API Example:

--------------------------------------
Cassandra API Example

---------------------------------
SQL API Example

-------------------------------------------------
MongoDB API Example

---------------------------------------------
Table API Example

-----------------------------------------------
PostgreSQL API Example



======================||==========================
========================||========================
# main.tf



---



###=======================================
# globals.tf
---






###=======================================
# variables.tf
---


---





###=======================================
# outputs.tf
---




---
### 




=====










╵=============================||=================================================

--------------------------------------------------


========


