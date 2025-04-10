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
The key point here is that when dealing with CMKs, versionless resource IDs should be used to ensure that the most recent key version is used by the service (e.g., Cosmos DB). If you directly reference the Key Vault key name from the Key Vault Key module and use it in the context of generating the normalized_cmk_key_url, the URL would still work correctly as long as the key name is valid.



=================||

I understand the suggestion to expose outputs for the key_vault_name and key_vault_key_name in the referenced modules. However, after careful consideration, I believe the current approach is necessary to meet the requirements for Customer Managed Keys (CMKs), particularly in relation to using versionless resource IDs.

Here’s why I’m sticking with the current approach:

Versionless Resource ID: The normalized_cmk_key_url needs to be versionless in order for the system to always use the latest version of the key, as expected by services like Cosmos DB. The key_vault_key_name is unique within the Key Vault, but to create a versionless resource ID (without a specific key version), I need to extract the necessary parts from the full key_vault_resource_id. This ensures that we can dynamically reference the current version of the key, which is critical for encryption and key management workflows.

Direct Outputs: Exposing outputs for these values, as suggested, would not directly provide the versionless resource ID required. Instead, it would still leave us needing to reference the full resource ID and extract the relevant components manually, which is what the current approach addresses. While it’s a valid suggestion, I believe the current logic is the most straightforward and efficient way to generate the correct normalized_cmk_key_url in this scenario.

For these reasons, I will continue with the current method of extracting the key_vault_name and key_vault_key_name from the full resource_id to ensure the URL is versionless and meets the CMK requirements.
----



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


