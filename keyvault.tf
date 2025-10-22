
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

------=========================
eShopOnWeb:    https://github.com/MicrosoftLearning/eShopOnWeb/blob/main/.ado/eshoponweb-cd-aci.yml
================================================||=====================

# build-te
------------


====||=====



========================|\========================

========================|\========================
### azure-pipelines-acr-jfrog.yaml

# azure-pipelines.yaml (lives in Project C)
name: $(Date:yyyyMMdd).$(Rev:r)

trigger:
  branches:
    include:
      - main
      - develop        # add whatever branches you want watched

# Optional: CI trigger on the app repo in Project B
resources:
  repositories:
    - repository: templates                # alias you’ll use for @-imports
      type: git
      name: ProjectA/TemplatesRepo         # <Project>/<Repo>
      ref: refs/heads/main                 # or a tag like refs/tags/v1.2.3
    - repository: app
      type: git
      name: ProjectB/MyAppRepo
      ref: refs/heads/main
      trigger:
        branches:
          include:
            - main                         # run when B/main changes

pool:
  vmImage: ubuntu-latest

stages:
- stage: Build
  displayName: Build App from Project B using templates from Project A
  jobs:
  - job: build
    steps:
      # Get the app code
      - checkout: app

      # Use a template file stored in Project A
      - template: pipelines/build.yml@templates
        parameters:
          projectPath: src/MyApp.sln
          configuration: Release









# build-d
----------







# build-d
-----------









build-d
===========||=========








----------------------------












======================================||=======================================================
======================================|\=======================================================
azure-p
========||=====
# azure-p



=====================||========

=============||================


====||=====



========================|\========================
azure-pipelines-jfrog-full.yaml
-------------------


===========||============
azure-pipelines-acr-full.yaml
























































































