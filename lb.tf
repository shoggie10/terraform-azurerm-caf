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
Build Unit tests for the module and work toe get as close to 80% code coverage as feasible.

https://gitlab.com/xxxx/terraform/aws/terraform-aws-xxxx-xxxxxxxxxx your GitLab account 

To Judge the Code Coverage,  use the following Checklist:

Does every resource in the module have at least one test case to verify it is being created as expected?

Is there at least one test case to check that the right number of resources are being created?

Is there at least one test case to check the naming to ensure it matches expected conventions?

Is there at least one test case for every module output that confirms the output is present and matches expected formats?

Is there at least one test case for every nested sub-module that confirms the submodule behaves as expected?

Is there at least two test cases for every “Count” iterator in a module that tests when the count is 0 and when the count is >0?

Are there multiple test cases for every for_each loop in the module that checks a variety of scenarios when different inputs are passed to ensure the behavior is as expected?

Is there a validation block on every input variable that expects the input to be in a specific format or match a specific value or set of values?

Is there a precondition on resources that checks the combination of two variables to ensure they are mutually valid?  (for example when the module expects EITHER variable A or variable B,  the pre-condition should throw an error if both variables were set,  etc.)

Is there test cases for “conditional logic” created by locals?  (For example,  if I have a Boolean local like “is_bucket_public” that changes the behavior of the module, I should have two test cases that test both options of the conditional logic)


=================||
Description
There was modified the test_r53_zone.tftest.hcl file which includes a set of unit tests for the module. Also, two optional variables were modified and one pre-condition was added to comply with the AWS constraints.

Knowledge Required

Domain: Terraform
Level: basic


Impact of Change
Users must now provide a valid input for "name", "comment" and "VPC" arguments. The introduced validation imposes stricter requirements on the variable's value.

Type of Change


 Update to existing module


Breaking Change


 Yes, this merge breaks existing usages of this module

 No, this merge does not break existing usages of this module


Checklist Before Requesting Reviewer


 I have run terraform-docs to generate the latest module documentation automatically.

 Terraform format (terraform fmt) has been applied.

 Terraform validate (terraform validate) passes without any errors.

 I have added or updated terraform tests to reflect the changes (if necessary).

 Terraform test (terraform test) passes without any errors.

 I have added a new entry to the CHANGELOG.md file.

 I have added or updated the examples to reflect the changes (if necessary).

 Variables and outputs are named consistently, documented, and logically grouped.

 All variables have proper descriptions.

 No hard-coded values that should be configurable.

 Secrets are managed securely.


Dependency Changes


 Are there any changes to modules, external sources, or data providers? Yes/No

 If yes, explain the impact and why these changes were necessary.


Screenshots (if applicable)

Additional Information
These changes are part of what was requested in this Jira ticket: CSE-11802

Notify


 Request review from peers who have worked on the module or are familiar with the infrastructure impacted.

 Teams dependent on this module have been informed if there are any breaking changes as part of this.



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


