
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

# - containers/build/azure-devops/templates/buildpushDockerImageTemplate.yml - buildAgentPoolName
### Pipeline template to build & push container to Jfrog or ACR Artifactory

# Build number format, where Major and Minor are pipeline variables defined
name: "$(Major).$(Minor).$(Rev:r)"

trigger:
- main
- master
- releases/*

# Pipeline Templates Reference, DO NOT MODIFY
resources:
  repositories:
  - repository: templates
    type: git
    name: azure-devops/Enterprise-Templates
    ref: 'refs/tags/vx.x'
    endpoint: PipelinesProd

pool:
  name: 'ubuntu-latest'

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
  - job: Build_And_Push_ACR
    displayName: "Build & Push to Azure Container Registry Job"
    pool: '$(buildAgentPoolName)'
    steps:
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
  - job: Build_And_Push_ACR
    displayName: "Build & Push to Azure Container Registry Job"
    pool: '$(buildAgentPoolName)'
    steps:
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

- stage: Manual_Approval
  displayName: "Manual Approval"
  dependsOn: BuildPushContainerImage
  condition: eq(dependencies.BuildPushContainerImage.outputs['Build_Container_Job.scanVariables.TrivyScanResults'], '1')
  jobs:
  - template:  containers/build/azure-devops/templates/manualInterventionJobTemplate.yml@templates   # Template reference
    parameters:
      DevOpsEnv: 'XXXXXX_DEV'









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
# Azure Pipelines (JFrog) - Full Parameter Passing
# Calls your build-docker-image-job.jfrog-template.yaml and supplies ALL template parameters directly.


# - containers/build/azure-devops/templates/buildpushDockerImageTemplate.yml - buildAgentPoolName
### Pipeline template to build & push container to Jfrog Artifactory

# Build number format, where Major and Minor are pipeline variables defined
name: "$(Major).$(Minor).$(Rev:r)"

trigger:
- main
- master
- releases/*

# Pipeline Templates Reference, DO NOT MODIFY
resources:
  repositories:
  - repository: templates
    type: git
    name: azure-devops/Enterprise-Templates
    ref: 'refs/tags/vx.x'
    endpoint: PipelinesProd

pool:
  name: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
- stage: BuildAndPush_JFrog
  displayName: "Build & Push to JFrog Artifactory"
  jobs:
  - job: Build_And_Push_ACR
    displayName: "Build & Push to Azure Container Registry Job"
    pool: '$(buildAgentPoolName)'
    steps:
    - template: build-docker-image-job.jfrog-template.yaml@templates   # Template reference
      parameters:
        # ---- Job metadata ----
        jobName: Build_Push_JFrog_Job
        jobDisplayName: "Build & Push Docker Image (Enterprise JFrog)"

        # ---- Artifact inputs ----
        artifactName: "drop"   # Pipeline artifact containing build output/  # The name of the pipeline artifact to download

        # ---- Docker build inputs ----
        imageName: "myapp"                       # Repo/image name (no registry)
        dockerfilePath: "src/MyApp/Dockerfile"
        workingDirectory: "src/MyApp"

        # For JFrog: split registry pieces
        containerRegistry: "jfrog.acme.org"        # Your JFrog Docker registry host
        imageRepositoryName: "docker-local"        # Target repo/key in Artifactory (e.g., docker-local)
        imageTags: |
          $(Build.BuildNumber)
          latest

        # ---- Connections ----
        serviceConnection: "JFrog-Service-Conn"    # JFrog service connection (ADO)

        # ---- Debug / Security ----
        enableDebugging: true
        trivyTemplateFilePath: "pipelines/build/azure-devops/junit.tpl"

        # ---- Architecture options ----
        enableMultiArch: true                      # Set to true to build/push a multi-arch manifest via buildx
        targetPlatforms: "linux/amd64,linux/arm64" # Modify as needed (e.g., linux/arm64 only)


- stage: Manual_Approval
  displayName: "Manual Approval"
  dependsOn: BuildPushContainerImage
  condition: eq(dependencies.BuildPushContainerImage.outputs['Build_Container_Job.scanVariables.TrivyScanResults'], '1')
  jobs:
  - template:  containers/build/azure-devops/templates/manualInterventionJobTemplate.yml@templates   # Template reference
    parameters:
      DevOpsEnv: 'XXXXXX_DEV'

===========||============
azure-pipelines-acr-full.yaml
-------------------
# Azure Pipelines (ACR) - Full Parameter Passing
# Calls your build-docker-image-job.acr-template.yaml and supplies ALL template parameters directly.

# - containers/build/azure-devops/templates/buildpushDockerImageTemplate.yml - buildAgentPoolName
### Pipeline template to build & push container to Jfrog Artifactory

# Build number format, where Major and Minor are pipeline variables defined
name: "$(Major).$(Minor).$(Rev:r)"

trigger:
- main
- master
- releases/*

# Pipeline Templates Reference, DO NOT MODIFY
resources:
  repositories:
  - repository: templates
    type: git
    name: azure-devops/Enterprise-Templates
    ref: 'refs/tags/vx.x'
    endpoint: PipelinesProd

pool:
  name: 'ubuntu-latest'

# Optional variables block if you prefer central control (edit or remove as you like)
variables:
  buildConfiguration: 'Release'

stages:
- stage: BuildAndPush_ACR
  displayName: "Build & Push to Azure Container Registry"
  jobs:
  - job: Build_And_Push_ACR
    displayName: "Build & Push to Azure Container Registry Job"
    pool: '$(buildAgentPoolName)'
    steps:
    - template: build-docker-image-job.acr-template.yaml@templates   # Template reference
      parameters:
        # ---- Job metadata ----
        jobName: Build_Push_ACR_Job
        jobDisplayName: "Build & Push Docker Image (ACR)"

        # ---- Artifact inputs ----
        artifactName: "drop"                  # Pipeline artifact containing build output/  # The name of the pipeline artifact to download

        # ---- Docker build inputs ----
        imageName: "myapp"                       # Repo/image name (no registry) to be created
        dockerfilePath: "src/MyApp/Dockerfile"   # Path to your Dockerfile (repo-relative) # Full path where the Dockerfile lives
        workingDirectory: "src/MyApp"            # Build context directory
        imageRepository: "myregistry.azurecr.io" # Registry DNS (e.g., <name>.azurecr.io)
        imageTags: |                             # One tag per line
          $(Build.BuildNumber)
          latest

        # ---- Registry / connections ----
        containerRegistryService: "ACR-Service-Conn"  # Azure DevOps service connection to ACR

        # ---- Debug / Security ----
        enableDebugging: false
        trivyTemplateFilePath: "pipelines/build/azure-devops/junit.tpl"

        # ---- Architecture options ----
        enableMultiArch: false                    # false = simple Docker@2 build; true = buildx
        targetPlatforms: "linux/amd64,linux/arm64" # Only used when enableMultiArch: true

- stage: Manual_Approval
  displayName: "Manual Approval"
  dependsOn: BuildPushContainerImage
  condition: eq(dependencies.BuildPushContainerImage.outputs['Build_Container_Job.scanVariables.TrivyScanResults'], '1')
  jobs:
  - template:  containers/build/azure-devops/templates/manualInterventionJobTemplate.yml@templates   # Template reference
    parameters:
      DevOpsEnv: 'XXXXXX_DEV'























































































