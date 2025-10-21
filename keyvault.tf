
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
# Azure Pipelines - Combined (ACR + JFrog)
# Runs ACR and/or JFrog stages based on branch conditions or toggle variables.
# Passes ALL applicable parameters directly to templates.

trigger:
- main
- master
- releases/*

variables:
  runAcr: 'true'     # set to 'false' to skip ACR stage
  runJfrog: 'false'  # set to 'true' to force JFrog stage outside release branches
  buildConfiguration: 'Release'

stages:
# ====================
# Stage: Build & Push to ACR
# ====================
- stage: BuildAndPush_ACR
  displayName: "Build & Push to Azure Container Registry"
  condition: or(eq(variables['runAcr'], 'true'), or(eq(variables['Build.SourceBranchName'], 'main'), eq(variables['Build.SourceBranchName'], 'master')))
  jobs:
    - template: build-docker-image-job.acr-template.yaml
      parameters:
        jobName: Build_Push_ACR_Job
        jobDisplayName: "Build & Push Docker Image (ACR)"
        artifactName: "drop"
        dockerfilePath: "src/MyApp/Dockerfile"
        workingDirectory: "src/MyApp"
        imageName: "myapp"
        imageRepository: "myregistry.azurecr.io"
        imageTags: |
          $(Build.BuildNumber)
          latest
        containerRegistryService: "ACR-Service-Conn"
        enableDebugging: false
        trivyTemplateFilePath: "pipelines/build/azure-devops/junit.tpl"
        enableMultiArch: false
        targetPlatforms: "linux/amd64,linux/arm64"

# ====================
# Stage: Build & Push to JFrog
# ====================
- stage: BuildAndPush_JFrog
  displayName: "Build & Push to JFrog Artifactory"
  condition: or(eq(variables['runJfrog'], 'true'), startsWith(variables['Build.SourceBranch'], 'refs/heads/releases/'))
  dependsOn: []
  jobs:
    - template: build-docker-image-job.jfrog-template.yaml
      parameters:
        jobName: Build_Push_JFrog_Job
        jobDisplayName: "Build & Push Docker Image (Enterprise JFrog)"
        artifactName: "drop"
        dockerfilePath: "src/MyApp/Dockerfile"
        workingDirectory: "src/MyApp"
        imageName: "myapp"
        imageTags: |
          $(Build.BuildNumber)
          latest
        containerRegistry: "jfrog.acme.org"
        imageRepositoryName: "docker-local"
        serviceConnection: "JFrog-Service-Conn"
        enableDebugging: true
        trivyTemplateFilePath: "pipelines/build/azure-devops/junit.tpl"
        enableMultiArch: true
        targetPlatforms: "linux/amd64,linux/arm64"










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
parameters:
- name: buildAgentPoolName
  default: ''
- name: artifactName
  default: 'Package'
- name: targetDeployRepo  # Ex: nuget-lib-snapshots-local
  default: ''
- name: packageRepositoryName  # SystemID
  default: ''
- name: packageName # Name of Package/application being created
  default: ''
- name: packageType  # Ex: nupkg, zip
  default: ''
- name: enableDebugging
  default: false

steps:
  # Download the build artifact. Files are downloaded to $(Pipeline.Workspace) by default
  - task: DownloadPipelineArtifact@2 
    displayName: Download Pipeline Artifacts
    inputs:
      source: 'current'
      artifact: '${{ parameters.artifactName }}'
      path: '$(Pipeline.Workspace)/${{ parameters.artifactName }}' 
#      patterns: '**/*.zip'

  - task: JFrogGenericArtifacts@1
    displayName: Push Packages to Jfrog Artifactory
    inputs:
      command: 'Upload'
      connection: "jfrog-artifactory-production-azdoci"
      specSource: 'taskConfiguration'
      fileSpec: |
        {
            "files": [
                {
                    "pattern": "$(Pipeline.Workspace)/${{ parameters.artifactName }}/${{ parameters.packageName }}.$(computedTag).${{ parameters.packageType }}",
                    "target": "${{ parameters.targetDeployRepo }}/${{ parameters.packageRepositoryName }}/${{ parameters.packageName }}/$(computedTag)/"
                }
            ]
        }
      collectBuildInfo: true
      buildName: '$(Build.DefinitionName)'
      buildNumber: '$(Build.BuildNumber)'
      failNoOp: true

  - task: JFrogPublishBuildInfo@1
    displayName: Publish Artifactory Build Info
    condition: and(succeeded(), or(startsWith(variables['Build.SourceBranch'], 'refs/heads/releases/'), eq(variables['Build.SourceBranchName'], 'main'), eq(variables['Build.SourceBranchName'], 'master')))
    inputs:
      artifactoryConnection: "jfrog-artifactory-production-azdoci"
      buildName: "$(Build.DefinitionName)"
      buildNumber: "$(Build.BuildNumber)"
























































































