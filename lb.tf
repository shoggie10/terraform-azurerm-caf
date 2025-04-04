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
List of Users in ADO: GET https://vssps.dev.azure.com/{organization}/_apis/graph/users?api-version=6.0-preview.1

GET https://vssps.dev.azure.com/{organization}/_apis/graph/users?api-version=6.0-preview.1
----
List of Projects in ADO: GET https://dev.azure.com/{organization}/_apis/projects?api-version=6.0
curl -u :<PAT> "https://dev.azure.com/{organization}/_apis/projects?api-version=6.0"
----
Azure CLI: az devops project list --organization https://dev.azure.com/{organization}

----
az devops user list --org $orgURL --query "members[].user.displayName" -o table


az devops user list --org $orgURL --query "members[].user.displayName" -o json |
  ConvertFrom-Json |
  Export-Csv -Path "users.csv" -NoTypeInformation



=================||
Subject: Updates on Azure DevOps Permissions and Resource Management Process

Dear Azure DevOps Users,

While using Terraform to manage Azure DevOps, we observed state drift that led us to identify some permissions that were unintentionally left behind during the initial implementation of the Limited Project Administrator (LPA) groups. These permissions have now been corrected.

Please note the following updates to the resource management process:

Resource Creation and Deletion: All resource creation or deletion must now be done via a ServiceNow request (ServiceNow Azure DevOps section) or through direct updates to the Terraform configurations in the ADO SaaS repository (Terraform ADO repository).

Permissions for LPAs and Other Groups: For detailed information about the permissions granted to LPAs and other groups within Azure DevOps, please refer to this document: LPA Permissions Overview.

Access to ADO SaaS Repo for Direct Terraform Changes: If you need access to the ADO SaaS repo for direct changes to Terraform configurations, please review the following documentation: Access Request Documentation.

We appreciate your attention to these updates, and thank you for your cooperation in ensuring proper resource management and access control.



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


