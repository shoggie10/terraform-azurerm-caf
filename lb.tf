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
Refactored the Cosmosdb_account module to include support for the SQL API and MongoDB API as part of the Azure Verified Module (AVM).

For APIs not supported by AVM, such as Table API and Cassandra API, a separate Cosmosdb_account module is used to manage their configurations.

Customer Managed Key (CMK) integration has been fully implemented within the module, providing enhanced security for CosmosDB accounts.


=================||




=====||====






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


