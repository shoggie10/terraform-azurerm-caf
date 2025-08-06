
module "keyvaults" {
  source   = "./modules/security/keyvault"
  for_each = var.keyvaults

  global_settings    = local.global_settings
  client_config      = local.client_config
  settings           = each.value
  diagnostics        = local.combined_diagnostics
  vnets              = local.combined_objects_networking
  virtual_subnets    = local.combined_objects_virtual_subnets
  azuread_groups     = local.combined_objects_azuread_groups
  managed_identities = local.combined_objects_managed_identities
  private_dns        = local.combined_objects_private_dns

  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)
}

#
# Keyvault access policies
#-
===============================================================================================
# main.tf
-------
As we approach our mid-year check-ins, I wanted to share a few important updates and expectations to help you prepare.
 
Per HR guidance, these check-ins are an opportunity to:
Reflect on your experience so far this year
Celebrate your accomplishments
Identify areas where additional support may be helpful
 
What I need from you:
Please ensure that each of your goals and core competencies in SuccessFactors is updated with:
A brief summary of your progress
At least one specific example of how you’ve met or demonstrated each goal or competency
 
This input is essential for a meaningful discussion and will help us focus on your growth and development.







# variables.tf
----------






# locals.tf
------------







# outputs.tf
----------





# examples.tf
-----------









===========||=========








----------------------------












======================================||=======================================================
======================================|\=======================================================


