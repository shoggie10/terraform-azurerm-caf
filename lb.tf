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
Updating the permissions to allow Repositories to be created directly in the ADO UI
We have mechanisms in place to ensure required separation of duties and minimum voter requirements are always met to allow teams to create repositories without admin intervention
Post creation of the repo, automation will remove overly permissive access given to the user that creates the repository.
Post creation of the repo, automation will grant all appropriate repository level permissions to the Limited Project Administrators group to allow management.
 
 
Updating customized permissions
After reviewing permissions across our Azure DevOps projects, we found many were customized by project administrators before switching to the limited project administrator role. To ensure consistency, we will implement the following changes:
YAML Pipeline Creation:
Modification of the Terraform code in the Azure DevOps repository in GitLab
Submission of a New ADO Pipeline request in Service Now
Classic Release Pipeline and Deployment Group permissions
Granted to the Limited Project Administrator group
Terraform previously lacked visibility into classic pipeline resources, which was missed.
Applies to only projects using this functionality
 
 
Updating the Automatically Included Reviewers Policy
Users requested a way to configure the project-level Automatically Included Reviewers policy. However, due to limitations, we cannot allow project users or administrators to manage these policies in the tool, as it would also grant the ability to modify or remove separation of duty and minimum reviewer policies. Therefore, these permissions need to be removed.
This has been implemented via a change to the Azure DevOps Project Terraform module.
Changes to project level review policies must now be submitted to the Azure DevOps repository in GitLab.
Submit an A@W request to obtain access if needed
Membership to an appropriate group in GitLab is also required for repository access

i think we can just take that whole section out, or at least reduce it to a "Based on feedback, you can make them in the tool" kind of language
=================||



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


