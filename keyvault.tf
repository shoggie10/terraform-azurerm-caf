
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
# resources: 
#   repositories: 
#   - repository: core_templates                          # Name repo reference for template ref
#     type: git                                           # Local ADO project type: git
#     name: BOKF.AzureDevOps.Templates/bokf-templates
#     ref: angular
# trigger:
#  branches:
#    include:
#     - master

parameters:
# Specify Node js Version
- name: specifyNodeVersion
  type: boolean
  default: false
- name: nodeVersion
  type: string
  default: '18.x'
- name: buildCommand # the command to run to build the angular app
  type: string
  default: 'run buildAzure'
- name: AngularBuildDirectory # the root folder the build 
  type: string
  default: '$(Build.SourcesDirectory)/dist'
- name: AngularWorkingDirectory # the root folder of the angular app
  type: string
  default: ''
- name: ArtifactName
  type: string
  default: 'drop'
  # Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'
- name: checkmarxProjectName
  type: string
  default: ''
- name: cxOneApplicationName
  default: ''
  type: string
- name: cxOneProjectGroup
  default: ''
  type: string
  # Jfrog Artifactory Config
- name: enableJFrogConfig
  type: boolean
  default: false
- name: jFrog_apiKey
  type: string
  default: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
- name: jFrog_email
  type: string
  default: 'dssupport@xxxx.com'
- name: jFrog_alwaysAuth
  type: boolean
  default: true
- name: jFrog_authToken
  type: string
  default: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  # Optionally enable testing, linting or prettier
- name: enableNGLint
  type: boolean
  default: false
- name: enableNGTest
  type: boolean
  default: false
- name: testCommand
  type: string
  default: 'run test-ci'
- name: testTimeoutInMinutes
  type: number
  default: 15
- name: enablePrettier
  type: boolean
  default: false
- name: prettierCommand
  type: string
  default: 'run prettier-check'
  # Artifact
- name: zipArtifactName
  type: string
  default: "$(Build.Repository.Name)_$(Build.BuildId)"
- name: testCoverageArtifactName
  type: string
  default: "angular-coverage-$(Build.BuildNumber)"
# pool items
- name: poolName
  type: string
  default: "Azure Pipelines"

jobs:
- job: "BuildAngular"
  pool:
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace(replace(replace(variables['System.TeamProject'], '.', ' '), 'BackOffice', 'Back Office'), 'InternalWeb', 'Internal Web')]

  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}

  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'BOKF.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'BOKF.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'BOKF.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'BOKFS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'BOKFS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'BOKFS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'BOKFS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}

  steps:
  - script: |+
      echo 'CxOneApplication Parameter =' ${{ parameters['cxOneApplicationName'] }} 
      echo 'appName =' $(appName)
      echo 'ProjectName =' $(projectName)
      echo 'ProjectGroup =' $(projectGroup)
        
  - checkout: self
    fetchDepth: 1

  - task: NodeTool@0
    displayName: "Install Node.js ${{ parameters.nodeVersion }}"
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}
    condition: eq('${{ parameters.specifyNodeVersion }}', 'true')

  - task: PowerShell@2
    displayName: 'List files in Angular working directory'
    inputs:
      targetType: 'inline'
      script: |
        $files = Get-ChildItem "${{ Parameters.AngularWorkingDirectory }}"
          Write-Host "List of files in ${{ Parameters.AngularWorkingDirectory }}"
          foreach ($file in $files) {
              Write-Host $file.Name
          }

  - task: PowerShell@2
    displayName: 'Create .npmrc file & add JFrog credentials'
    condition: eq('${{ Parameters.enableJFrogConfig }}', 'true')
    inputs:
      targetType: 'inline'
      script: |
        $authToken = "${{ Parameters.jFrog_authToken }}"

        # Change directory to Angular Working Directory
        Set-Location -Path "${{ Parameters.AngularWorkingDirectory }}"

        New-Item -Path ".npmrc" -ItemType File -Force

        Add-Content -Path ".npmrc" -Value "@bokf:registry=https://bokdsg.jfrog.io/artifactory/api/npm/bok-npm-local/"
        Add-Content -Path ".npmrc" -Value "//bokdsg.jfrog.io/artifactory/api/npm/bok-npm-local/:_authToken='$authToken'"

        Get-Content -Path ".npmrc"

        # List all files in the current directory
        Get-ChildItem | Select-Object -ExpandProperty Name

  - task: Npm@1
    displayName: 'Install npm dependencies'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'install'

  - task: Npm@1
    condition: eq('${{ Parameters.enableNGLint }}', 'true')
    displayName: 'Lint Angular application'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: 'run lint'
      continueOnError: false

  - task: Npm@1
    condition: eq('${{ Parameters.enablePrettier }}', 'true')
    displayName: 'NPM Custom - Install nx'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: 'install nx'
      continueOnError: false

  - task: Npm@1
    condition: eq('${{ Parameters.enablePrettier }}', 'true')
    displayName: 'Run Prettier tests'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.prettierCommand }}
      continueOnError: false

  - task: Npm@1
    condition: eq('${{ Parameters.enableNGTest }}', 'true')
    displayName: 'Run Angular tests'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.testCommand }}
      timeoutInMinutes: ${{ Parameters.testTimeoutInMinutes }}
      continueOnError: false
  # Publish test coverage for SonarQube analysis
  - task: PublishPipelineArtifact@1
    condition: eq('${{ Parameters.enableNGTest }}', 'true')
    displayName: 'Publish Angular Tests (Sonar)'
    inputs:
      targetPath: '${{ Parameters.AngularWorkingDirectory }}/coverage'
      artifact: '${{ Parameters.testCoverageArtifactName }}'

  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: $(appName)
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: Npm@1
    displayName: 'Build Angular application'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.buildCommand }}

  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        
        $files = Get-ChildItem "${{ Parameters.AngularBuildDirectory }}"
          Write-Host "List of files in ${{ Parameters.AngularBuildDirectory }}"
          foreach ($file in $files) {
              Write-Host $file.Name
          }
  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        $ZipFile = "$(Build.ArtifactStagingDirectory)/${{ parameters.zipArtifactName }}.zip"
        Compress-Archive -Path "${{ Parameters.AngularBuildDirectory }}/*" -DestinationPath $ZipFile
      displayName: 'Zip Artifacts'

  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        
        $files = Get-ChildItem "$(Build.ArtifactStagingDirectory)"
          Write-Host "List of files in $(Build.ArtifactStagingDirectory)"
          foreach ($file in $files) {
              Write-Host $file.Name
          }

  - task: PublishBuildArtifacts@1
    displayName: "Publish build artifacts to Azure Pipelines"
    enabled: true
    inputs:
      PathtoPublish: "$(Build.ArtifactStagingDirectory)/${{ parameters.zipArtifactName }}.zip"
      ArtifactName: "${{ Parameters.ArtifactName }}"
      publishLocation: "Container"
==============||=======
CustomBSSAngulaApp.yaml
# resources: 
#   repositories: 
#   - repository: core_templates                          # Name repo reference for template ref
#     type: git                                           # Local ADO project type: git
#     name: xxxx.AzureDevOps.Templates/xxxx-templates
#     ref: angular
# trigger:
#  branches:
#    include:
#     - master

parameters:
# Specify Node js Version
- name: specifyNodeVersion
  type: boolean
  default: false
- name: nodeVersion
  type: string
  default: '18.x'
- name: buildCommand # the command to run to build the angular app
  type: string
  default: 'run buildAzure'
- name: AngularBuildDirectory # the root folder the build 
  type: string
  default: '$(Build.SourcesDirectory)/dist'
- name: AngularWorkingDirectory # the root folder of the angular app
  type: string
  default: ''
- name: ArtifactName
  type: string
  default: 'drop'
  # Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'
- name: cxOneApplicationName
  default: ''
  type: string
- name: cxOneProjectGroup
  default: ''
  type: string
- name: checkmarxProjectName
  type: string
  default: ''
  # Vulnerability Threshold Options

  # Jfrog Artifactory Config
- name: enableJFrogConfig
  type: boolean
  default: false
- name: jFrog_apiKey
  type: string
  default: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
- name: jFrog_email
  type: string
  default: 'dssupport@xxxx.com'
- name: jFrog_alwaysAuth
  type: boolean
  default: true
- name: jFrog_authToken
  type: string
  default: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
- name: bss_authToken
  type: string
  # Optionally enable testing, linting or prettier
- name: enableNGLint
  type: boolean
  default: false
- name: enableNGTest
  type: boolean
  default: false
- name: testCommand
  type: string
  default: 'run test-ci'
- name: testTimeoutInMinutes
  type: number
  default: 15
- name: enablePrettier
  type: boolean
  default: false
- name: prettierCommand
  type: string
  default: 'run prettier-check'
  # Artifact
- name: zipArtifactName
  type: string
  default: "$(Build.Repository.Name)_$(Build.BuildId)"
- name: testCoverageArtifactName
  type: string
  default: "angular-coverage-$(Build.BuildNumber)"
  #pool items
- name: poolName
  type: string
  default: "Azure Pipelines"
jobs:
- job: "BuildAngular"
  pool:
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace (replace(replace(variables['System.TeamProject'], '.', ' '),'BackOffice','Back Office'),'InternalWeb','Internal Web')]

  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}
  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}
  steps:
  - checkout: self
    fetchDepth: 1
  - task: NodeTool@0
    displayName: "Install Node.js ${{ parameters.nodeVersion }}"
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}
    condition: eq('${{ parameters.specifyNodeVersion }}', 'true')
  - task: PowerShell@2
    displayName: 'List files in Angular working directory'
    inputs:
      targetType: 'inline'
      script: |
        $files = Get-ChildItem "${{ Parameters.AngularWorkingDirectory }}"
          Write-Host "List of files in ${{ Parameters.AngularWorkingDirectory }}"
          foreach ($file in $files) {
              Write-Host $file.Name
          }
  - task: PowerShell@2
    displayName: 'Create .npmrc file & add JFrog credentials'
    condition: eq('${{ Parameters.enableJFrogConfig }}', 'true')
    inputs:
      targetType: 'inline'
      script: |
        $authToken = "${{ Parameters.jFrog_authToken }}"
        $bssauthToken = "${{ Parameters.bss_authToken }}"
        # Change directory to Angular Working Directory
        Set-Location -Path "${{ Parameters.AngularWorkingDirectory }}"
        New-Item -Path ".npmrc" -ItemType File -Force

        Add-Content -Path ".npmrc" -Value "@xxxx:registry=https://bokdsg.jfrog.io/artifactory/api/npm/bok-npm-local/"
        Add-Content -Path ".npmrc" -Value "//bokdsg.jfrog.io/artifactory/api/npm/bok-npm-local/:_authToken='$authToken'"
        Add-Content -Path ".npmrc" -Value "@bss:registry=https://pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/registry/"
        Add-Content -Path ".npmrc" -Value "; begin auth token"
        Add-Content -Path ".npmrc" -Value "//pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/registry/:username=xxx"
        Add-Content -Path ".npmrc" -Value "//pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/registry/:_password=$bssauthToken"
        Add-Content -Path ".npmrc" -Value "//pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/registry/:email=xxx@xxxx.com"
        Add-Content -Path ".npmrc" -Value "//pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/:username=xxx"
        Add-Content -Path ".npmrc" -Value "//pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/:_password=$bssauthToken"
        Add-Content -Path ".npmrc" -Value "//pkgs.dev.azure.com/xxxx/_packaging/BSS-Support/npm/:email=xxx@xxxx.com"
        Add-Content -Path ".npmrc" -Value "; end auth token"
        Get-Content -Path ".npmrc"

        # List all files in the current directory
        Get-ChildItem | Select-Object -ExpandProperty Name
  - task: Npm@1
    displayName: 'Install npm dependencies'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'install'
  - task: Npm@1
    condition: eq('${{ Parameters.enableNGLint }}', 'true')
    displayName: 'Lint Angular application'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: 'run lint'
    continueOnError: false
  - task: Npm@1
    condition: eq('${{ Parameters.enablePrettier }}', 'true')
    displayName: 'NPM Custom - Install nx'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: 'install nx'
    continueOnError: false
  - task: Npm@1
    condition: eq('${{ Parameters.enablePrettier }}', 'true')
    displayName: 'Run Prettier tests'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.prettierCommand }}
    continueOnError: false
  - task: Npm@1
    condition: eq('${{ Parameters.enableNGTest }}', 'true')
    displayName: 'Run Angular tests'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.testCommand }}
    timeoutInMinutes: ${{ Parameters.testTimeoutInMinutes }}
    continueOnError: false
    # Publish test coverage for SonarQube analysis
  - task: PublishPipelineArtifact@1
    condition: eq('${{ Parameters.enableNGTest }}', 'true')
    displayName: 'Publish Angular Tests (Sonar)'
    inputs:
      targetPath: '${{ Parameters.AngularWorkingDirectory }}/coverage'
      artifact: '${{ Parameters.testCoverageArtifactName }}'
    # Add CxOne scan template
  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: $(appName)
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: Npm@1
    displayName: 'Build Angular application'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.buildCommand }}
  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        
        $files = Get-ChildItem "${{ Parameters.AngularBuildDirectory }}"
          Write-Host "List of files in ${{ Parameters.AngularBuildDirectory }}"
          foreach ($file in $files) {
              Write-Host $file.Name
          }
  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        $ZipFile = "$(Build.ArtifactStagingDirectory)/${{ parameters.zipArtifactName }}.zip"
        Compress-Archive -Path "${{ Parameters.AngularBuildDirectory }}/*" -DestinationPath $ZipFile
    displayName: 'Zip Artifacts'
  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        
        $files = Get-ChildItem "$(Build.ArtifactStagingDirectory)"
          Write-Host "List of files in $(Build.ArtifactStagingDirectory)"
          foreach ($file in $files) {
              Write-Host $file.Name
          }
  - task: PublishBuildArtifacts@1
    displayName: "Publish build artifacts to Azure Pipelines"
    enabled: true
    inputs:
      PathtoPublish: "$(Build.ArtifactStagingDirectory)/${{ parameters.zipArtifactName }}.zip"
      ArtifactName: "${{ Parameters.ArtifactName }}"
      publishLocation: "Container"





===============||===========
Package_build_pulish.yaml
parameters:
- name: enableDebug
  type: boolean
  default: true
- name: packageVersion
  type: string
  default: "0.0.$(Build.BuildNumber)"

# Build stage parameters
- name: specifyNodeVersion
  type: boolean
  default: true
- name: nodeVersion
  type: string
  default: "20.x"
- name: buildCommand
  type: string
  default: 'run build-prod'

# Do not use these defaults, Always set your working, project, and build directory
- name: AngularBuildDirectory
  type: string
  default: '$(Build.SourcesDirectory)/dist'
# the root of the angular working directory that will be used for npm install and build
- name: AngularWorkingDirectory
  type: string
  # default: '$(Build.SourcesDirectory)/'
  # this path is used for setting the version of specific package being published
- name: AngularProjectDirectory
  type: string
  # default: '$(Build.SourcesDirectory)/'

  # Testing parameters
- name: enableNGTest
  type: boolean
  default: false
- name: testCommand
  type: string
  default: 'run test-ci'
- name: testTimeoutInMinutes
  type: number
  default: 15

- name: targetPathtoPublish
  type: string
  default: "$(Build.ArtifactStagingDirectory)"
- name: ArtifactName
  type: string
  default: "drop"

- name: jFrog_authToken
  type: string
  default: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'

- name: cxOneApplicationName
  default: ''
  type: string

- name: cxOneProjectGroup
  default: ''
  type: string

- name: checkmarxProjectName
  type: string
  default: ''

# Publish stage parameters
- name: enablePublish
  type: boolean
  default: false
- name: AgentBuildPath
  type: string
  default: "$(System.ArtifactsDirectory)"
- name: publishFeedID
  type: string

# pool items
- name: poolName
  type: string
  default: "Azure Pipelines"

jobs:
- job: Build
  pool:
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace (replace(replace(variables['System.TeamProject'], '.', ' '),'BackOffice','Back Office'),'InternalWeb','Internal Web')]
  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}
  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}
  displayName: "Angular Library Build"
  workspace:
    clean: all
  steps:
  - checkout: self
    fetchDepth: 1

  - task: NodeTool@0
    condition: eq('${{ parameters.specifyNodeVersion }}', 'true')
    displayName: "Install Node.js ${{ parameters.nodeVersion }}"
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}

  - task: PowerShell@2
    enabled: ${{ parameters.enableDebug }}
    displayName: "List files in Angular working directory"
    inputs:
      targetType: "inline"
      script: |
        $files = Get-ChildItem "${{ parameters.AngularWorkingDirectory }}"
        Write-Host "List of files in ${{ parameters.AngularWorkingDirectory }}"
        foreach ($file in $files) {
          Write-Host $file.Name
        }

  - task: PowerShell@2
    displayName: "Create .npmrc file & add JFrog credentials"
    inputs:
      targetType: "inline"
      script: |
        $authToken = "${{ parameters.jFrog_authToken }}"

        # Change directory to Angular Working Directory
        Set-Location -Path "${{ parameters.AngularWorkingDirectory }}"

        New-Item -Path ".npmrc" -ItemType File -Force

        Add-Content -Path ".npmrc" -Value "@xxxx:registry=https://bokdsg.jfrog.io/artifactory/api/npm/bok-npm-local/"
        Add-Content -Path ".npmrc" -Value "//bokdsg.jfrog.io/artifactory/api/npm/bok-npm-local/:_authToken='$authToken'"

        Get-Content -Path ".npmrc"


        # List all files in the current directory
        Get-ChildItem | Select-Object -ExpandProperty Name

  - task: Npm@1
    displayName: "Install npm dependencies"
    inputs:
      workingDir: ${{ parameters.AngularWorkingDirectory }}
      command: "install"

  - script: |
      cd ${{ parameters.AngularProjectDirectory }}
      npm --no-git-tag-version version ${{ parameters.packageVersion }}
    displayName: "Update pkg version to ${{ parameters.packageVersion }}"

  - task: Npm@1
    displayName: "NG Lint"
    inputs:
      workingDir: ${{ parameters.AngularWorkingDirectory }}
      command: "custom"
      customCommand: "run lint"

  - task: Npm@1
    displayName: "Run Prettier check"
    inputs:
      workingDir: ${{ parameters.AngularWorkingDirectory }}
      command: "custom"
      customCommand: "run prettier-check"

  - task: Npm@1
    condition: eq('${{ Parameters.enableNGTest }}', 'true')
    displayName: 'Run Angular tests'
    inputs:
      workingDir: ${{ Parameters.AngularWorkingDirectory }}
      command: 'custom'
      customCommand: ${{ Parameters.testCommand }}
    timeoutInMinutes: ${{ Parameters.testTimeoutInMinutes }}
    continueOnError: false

  # Replace old Checkmarx AST task with template
  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: $(appName)
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: Npm@1
    displayName: "Build Angular application"
    inputs:
      workingDir: ${{ parameters.AngularWorkingDirectory }}
      command: "custom"
      customCommand: ${{ parameters.buildCommand }}

  - task: PowerShell@2
    enabled: ${{ parameters.enableDebug }}
    displayName: "Listing all files in ${{ parameters.AngularBuildDirectory }}"
    inputs:
      targetType: "inline"
      script: |
        $files = Get-ChildItem "${{ parameters.AngularBuildDirectory }}"
        Write-Host "List of files in ${{ parameters.AngularBuildDirectory }}"
        foreach ($file in $files) {
          Write-Host $file.Name
        }

  - task: CopyFiles@2
    displayName: Copy Angular build dist contents
    inputs:
      SourceFolder: ${{ parameters.AngularBuildDirectory }}
      Contents: "**"
      TargetFolder: $(Build.ArtifactStagingDirectory)

  - task: PowerShell@2
    enabled: ${{ parameters.enableDebug }}
    displayName: "Listing all files in $(Build.ArtifactStagingDirectory)"
    inputs:
      targetType: "inline"
      script: |
        $files = Get-ChildItem "$(Build.ArtifactStagingDirectory)"
        Write-Host "List of files in $(Build.ArtifactStagingDirectory)"
        foreach ($file in $files) {
          Write-Host $file.Name
        }

  - task: PublishPipelineArtifact@1
    displayName: "Publish build artifacts to Azure Pipelines"
    inputs:
      targetPath: ${{ parameters.targetPathtoPublish }}
      artifactName: "${{ parameters.ArtifactName }}"
      artifactType: "pipeline"

- job: Publish
  dependsOn: Build
  condition: and(succeeded('Build'), ${{ parameters.enablePublish }})
  displayName: "Publish npm package"
  workspace:
    clean: all
  steps:
  - task: DownloadPipelineArtifact@2
    inputs:
      source: "current"
      artifact: "${{ parameters.ArtifactName }}"
      path: ${{ parameters.AgentBuildPath }}

  - task: PowerShell@2
    enabled: ${{ parameters.enableDebug }}
    displayName: "Listing all files in AgentBuildPath ${{ parameters.AgentBuildPath }}"
    inputs:
      targetType: "inline"
      script: |
        $files = Get-ChildItem "${{ parameters.AgentBuildPath }}"
        Write-Host "List of files in ${{ parameters.AgentBuildPath }}"
        foreach ($file in $files) {
          Write-Host $file.Name
        }

  - task: Npm@1
    inputs:
      command: "publish"
      workingDir: ${{ parameters.AgentBuildPath }}
      publishRegistry: useFeed
      publishFeed: ${{ parameters.publishFeedID }}
    displayName: "Publish npm package"






# variables.tf
----------
Dot4orLower
#xxxx Custom Template for .NET <=4.8 or Lower Build Pipeline
#v0.0.3 Extensible

parameters:
#Nuget and VSBuild Stage Parameters
- name: enableNugetRestore
  type: boolean
  default: true
- name: enableMSBuild
  type: boolean
  default: true
- name: solution
  type: string
- name: buildPlatform
  default: ""
  type: string
- name: buildConfiguration
  default: "Release"
  type: string
- name: msBuildArguments
  default: '/t:Rebuild'
  type: string
- name: vsVersion
  type: string
  default: "latest"
  #ExtractFiles Stage Parameters
- name: enableExtractFiles
  type: boolean
  default: false
- name: packageLocation
  default: "PackageLocation"
  type: string
- name: destinationPackageFolder
  default: "$(packageLocation)/ExtractedFiles"
  type: string
  #Stage Files for Artifact Publish
- name: enablePipelinePublish
  type: boolean
  default: true
- name: copyContents
  type: object # any YAML structure
  #default: '**'
- name: copyContentsSourceFolder
  type: string
  default: "$(system.defaultworkingdirectory)"

- name: targetFolder
  type: string
  default: "$(build.artifactstagingdirectory)"
- name: targetFolderAppend
  type: string
  default: ''
  # Enable or Disable NuGet Pack
- name: nugetPack
  type: boolean
  default: false
- name: nuGetFeedType
  type: string
  default: 'internal'
- name: InternalNugetFeed # Feed to include internal Nuget libraries
  type: string
  default: "DSG.BackOffice"
- name: pushNugetFeed
  type: string
  default: 'b4a8bfe1-e379-4eaa-8cc9-f66bca680d0a'
  #VSTest
- name: vsTestEnabled
  type: boolean
  default: true
  # Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'
- name: cxOneApplicationName
  default: ''
  type: string
- name: cxOneProjectGroup
  default: ''
  type: string
- name: checkmarxProjectName
  type: string
  default: ''
  #Publish artifact to Azure Pipelines
- name: artifactName
  type: string
  default: "drop"
  #tests code coverage
- name: codeCoverageCollector
  type: string
  default: "XPlat Code Coverage"
- name: codeCoverageSummaryFile
  type: string
  default: "$(Agent.TempDirectory)/**/coverage.cobertura.xml"
- name: codeCoverageSummaryDirectory
  type: string
  default: "$(Agent.TempDirectory)"
  # Artifact
- name: zipArtifactName
  type: string
  default: "$(Build.Repository.Name)_$(Build.BuildId)" # pool items
- name: poolName
  type: string
  default: "Azure Pipelines"

# Build stages of pipeline 
jobs:
- job: "BuildPipeline"
  pool:
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace (replace(replace(variables['System.TeamProject'], '.', ' '),'BackOffice','Back Office'),'InternalWeb','Internal Web')]

  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}
  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}
  steps:
  - script: echo "appName is:" $(appName)
  - script: echo "CxApplicationNAme:"  ${{ parameters['cxOneApplicationName'] }}
  - script: echo 'ProjectName =' $(projectName)
  - script: echo 'ProjectGroup =' $(projectGroup)
  - task: NuGetToolInstaller@1
    displayName: "NuGet tool install"
  - task: NuGetCommand@2
    enabled: ${{ parameters.enableNugetRestore }}
    displayName: "NuGet restore"
    inputs:
      restoreSolution: "${{ parameters.solution }}"
      vstsFeed: ${{ Parameters.InternalNugetFeed }}
      includeNuGetOrg: true
    # Add CxOne scan template before build
  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: $(appName) #${{ parameters['cxOneApplicationName'] }}
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: VSBuild@1
    displayName: "Build solution"
    enabled: ${{ parameters.enableMSBuild }}
    inputs:
      solution: "${{ parameters.solution }}"
      platform: "${{ parameters.BuildPlatform }}"
      configuration: "${{ parameters.BuildConfiguration }}"
      msbuildArgs: "${{ parameters.msBuildArguments }}"
      vsVersion: "${{ parameters.vsVersion }}"

  - task: ExtractFiles@1
    displayName: "Extract Files"
    enabled: ${{ parameters.enableExtractFiles }}
    inputs:
      archiveFilePatterns: '${{ parameters.packageLocation }}/*.zip'
      destinationFolder: '${{ parameters.destinationPackageFolder }}'
    condition: succeededOrFailed()

  - task: CopyFiles@2
    displayName: "Copy Files to: ${{ parameters.targetFolder }}"
    inputs:
      SourceFolder: "${{ parameters.copyContentsSourceFolder }}"
      Contents: "${{ parameters.copyContents }}"
      TargetFolder: "${{ parameters.targetFolder }}"
      CleanTargetFolder: true
    condition: succeededOrFailed()

  - task: VSTest@2
    displayName: "Run VSTest stage"
    enabled: ${{ parameters.vsTestEnabled }}
    inputs:
      platform: "${{ parameters.buildPlatform }}"
      configuration: "${{ parameters.buildConfiguration }}"

  - powershell: |
      $solutionPattern = "${{ parameters.solution }}"
      if ($solutionPattern -like '*\*.sln' -or $solutionPattern -like '*.sln') {
        $solutionFiles = Get-ChildItem -Path $solutionPattern -Recurse -ErrorAction SilentlyContinue
        if ($solutionFiles.Count -eq 0) {
          Write-Error "No solution files found matching pattern: $solutionPattern"
          exit 1
        }
        $solutionPath = $solutionFiles[0].FullName
      } else {
        $solutionPath = $solutionPattern
      }
      $buildConfig = "${{ Parameters.buildConfiguration }}"
      $coverageCollector = "${{ Parameters.codeCoverageCollector }}"
      $coverageDir = "${{ Parameters.codeCoverageSummaryDirectory }}"
      dotnet test "$solutionPath" --configuration "$buildConfig" --collect:"$coverageCollector" --results-directory "$coverageDir"
    displayName: 'Get code coverage results'
    enabled: ${{ parameters.vsTestEnabled }}

  - task: PublishCodeCoverageResults@2
    displayName: "Publish code coverage results"
    enabled: ${{ parameters.vsTestEnabled }}
    inputs:
      summaryFileLocation: "${{ Parameters.codeCoverageSummaryFile }}"

  - task: ArchiveFiles@2
    displayName: 'ZipFiles'
    enabled: true
    inputs:
      replaceExistingArchive: true
      rootFolderOrFile: '$(Build.ArtifactStagingDirectory)${{ parameters.targetFolderAppend }}*'
      archiveFile: "$(Build.ArtifactStagingDirectory)${{ parameters.targetFolderAppend }}${{ parameters.zipArtifactName }}.zip"

  - task: PublishBuildArtifacts@1
    displayName: "Publish build artifacts to Azure Pipelines"
    enabled: ${{ parameters.enablePipelinePublish }}
    inputs:
      PathtoPublish: "$(Build.ArtifactStagingDirectory)${{ parameters.targetFolderAppend }}${{ parameters.zipArtifactName }}.zip"
      ArtifactName: "${{ parameters.artifactName }}"
      publishLocation: "Container"

  - task: NuGetCommand@2
    displayName: 'NuGet pack'
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: pack
      versioningScheme: byPrereleaseNumber
      configuration: '${{ parameters.buildConfiguration }}'

  - task: NuGetCommand@2
    displayName: 'NuGet push'
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: push
      #nuGetFeedType:'${{ parameters.nuGetFeedType }}'
      publishVstsFeed: '${{ parameters.pushNugetFeed }}'
==================+||======================
EADm.m
# .NET <=4.x Build Pipeline Template 
This directory contains versions of a build pipeline designed to build .NET applications using .NET 4.x or lower.  

**Latest release version:** v0.0.02

High Level Overview:
 
This is a build pipeline that on manual run or a change pushed to the master branch of a repository will: 
- Request a Microsoft hosted agent with the ability to run this .NET framework build 
- Install NuGet and restore any requested packages 
- Build solution 
- Copy required files from the working directory on the agent to the artifact staging directory 
- Run VSTest tests as configured
- Run Checkmarx preset and create report 
- Publish the files to Azure Pipelines as a downloadable zip 

Table of Contents: 
- [How to Use These Templates](#how-to-use-these-templates) 
- [Stages and options](#stages)
- [Versions and release notes](#versions-and-release-notes)

## How to Use These Templates 

Replace the following run variables: 

### NuGet and VSBuild Stage Variables 

| Variable | Default | Description | Format | 
| -------- | ------- | ----------- | ------ | 
| solution | None | Path to sln file located in your repo used by Nuget Restore and MSBuild | `'<solution_file_path>.sln'` | 
| buildPlatform | 'Any CPU' | Specifies build platform for VSBuild and VSTest stages | String `'value'`|
| buildConfiguration | 'Release' | Build configuration for VSBuild and VSTest Stages | `'value'` | 
| msBuildArguments | None | Provide any required MSBuild arguments (target, etc) | String | 

### Stage Files for Artifact Publish Variables 
| Variable | Default | Description | Format | 
| -------- | ------- | ----------- | ------ | 
| copyContents | `**/bin/$(buildConfiguration)/**` | Provide list of files to include/exclude from copy to staging directory | `**/path_to_include/**, !<path_to_exclude*/**` | 
| targetFolder | '$(build.artifactstagingdirectory)' | Staging directory to copy files into | String | 

### Checkmarx Application Security Testing
Please ensure that a Checkmarx service connection that the pipeline can access has been configured at either the project or organization level for your pipeline to access and provide that information to your pipeline via the variables below. 

If you are not sure, check Settings > Service Connections in ADO, but note that your user settings may prevent you from viewing connections. For more information on configuring a service connection in ADO projects, see [Microsoft Documentation on configuring service connections.](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) 


| Variable | Default | Description | Format | 
| -------- | ------- | ----------- | ------ | 
| cmxScanEnabled | true | Enable or disable Checkmarx scan stage | true / false | 
| checkmarxProjectName | None, provide as 'BAU-<ProjectName>'.  This will be created in Checkmarx on run if it does not exist. | Name of project in Checkmarx | `'BAU-<ProjectName>' | 
| checkmarxServiceConnection | 'BAUCheckmarxConnection' | Name of your configured service connection for Checkmarx in ADO Service Connections |  `'<NameofServiceConnection>'` | 
| preset| 'High and Medium' | The name of the desired preset in Checkmarx to run.  Default for xxxx projects is 'High and Medium' | `'Preset Name'` | 
| fullTeamName | 'CxServer\DSG\Back-Office\BAU' | The full team name. If team is mentioned in Service connection,then this will get overridden with Service connection Team | 'CxServer\SP\Company\Users' | 
| enableDependencyScan | false | Enables or disables dependency scan | true / false  | 
| enableProxy | false | Enable/disable proxy use. (Proxy Settings are configured on the agent level) | true/false  | 
| enableSastScan | true | Select in order to enable the CxSast scan | true/false | 

# VSTest 
| Variable | Default | Description | Format | 
| -------- | ------- | ----------- | ------ | 
| vsTestEnabled | true | Enables or disables VSTest | true or false | 

### Publish artifact to Azure Pipelines
| Variable | Default | Description | Format | 
| -------- | ------- | ----------- | ------ | 
| artifactName |  'drop' | Name of artifact published to Azure Pipelines, defaults to 'drop' | `'value'` |  


## Stages 

### Trigger 
This template is set up with a trigger to run automatically when changes are committed to the master branch of the repository: 

```yaml
trigger:
 branches:
   include:
    - master
```
To run this pipeline template for other branches of this repository, visit the pipeline in ADO interface and select "Run" > "Branch selection".  

**NOTE**: When running this pipeline from non-master branches, **the YAML pipeline file in the induvidual branch run will be the pipeline stages run.**  If updates are made to the azure-pipeline.yaml file in master branch, other branches must rebase to get those changes to their pipeline runs.  

### Agent Pool 
This template requires a Windows latest agent to build.

```yaml
pool:
 name: ${{ Parameters.poolName }}
  vmImage: 'windows-latest'
```

### Tasks 

1. **NuGetToolInstaller@1:** Installs preferred version of Nuget. [Documentation for NuGet install.](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/nuget-tool-installer-v1?view=azure-pipelines)

    ```yaml 
        # NuGet tool installer
        # Acquires a specific version of NuGet from the internet or the tools cache and adds it to the PATH. Use this task to change the version of NuGet used in the NuGet tasks.
      - task: NuGetToolInstaller@1
        inputs:
          #versionSpec: # Optional
          #checkLatest: false # Optional
        ```

2. **VSBuild@1:** Microsoft reccomended stage for building .NET projects; runs MSBuild to build solution according to parameters and arguments provided. [Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/build/visual-studio-build?view=azure-devops)

3. **ExtractFiles@1:**  Extracts files from archives to a specified directory. This task supports various archive formats like .zip, .tar, .tar.gz, and more. The task is conditionally enabled based on the enableExtractFiles parameter, and uses the packageLocation and destinationPackageFolder parameters to determine the source and destination paths. [Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/extract-files-v1?view=azure-pipelines)

4. **CopyFiles@2:** Copies specified files from build working directory into artifact staging directory for publishing as an artifact.  Using this stage allows for inclusion or exclusion of specific files, similar to Jenkins archive files stage post-build. [Documentation, file match patterns and additional options can be found here.](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/copy-files?view=azure-devops&tabs=yaml)

5. **VSTest@2:** Runs VS tests (can be enabled or disabled dependant on application). Use this task to run unit and functional tests (Selenium, Appium, Coded UI test, and more) using the Visual Studio Test Runner. [Documentation on what type of tests are supported and how to specify VSTest settings can be found in this documentation.](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/vstest-v2?view=azure-pipelines)

6. **Checkmarx Scan: Application security testing@2022**: Runs the requested Checkmarx preset. 

    **Default preset for xxxx is:** 'High and Medium'.  

    For more information about available settings in ADO checkmarx plugin, visit: [Documentation](https://checkmarx.atlassian.net/wiki/spaces/SD/pages/6006276963/Running+a+Scan+from+Azure+DevOps)

    Vulnerability Threshold to Auto-Fail Builds 
    To auto-fail builds based on Checkmarx vulnerabilities, the following threshold options have been implemented for Checkmarx scan stage: 
    

    ```yaml
    steps:
    - task: checkmarx.cxsast.cx-scan-task.Application security testing@2022
    displayName: 'Application security testing'
    inputs:
        projectName: 'test-project'
        vulnerabilityThreshold: true                       # Ability to enable a threshold 
        failBuildForNewVulnerabilitiesEnabled: true        # Enable/disable failing build for new vulns
        failBuildForNewVulnerabilitiesSeverity: HIGH       # Set type of new vulnerability to fail build on
        high: 1                                            # Set number of high vulns to fail on
        medium: 5                                          # Set number of medium vulns to fail on
        low: 0                                             # Set number of low vulns to fail on
    ```

7. **ArchiveFiles@2:**: Archives files into a .zip file. This task can replace existing archives and is configured to archive files from the specified root folder or file. The rootFolderOrFile and archiveFile parameters are used to determine the source and destination of the archive. Documentation for the Archive Files task can be found here.[Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/archive-files-v2?view=azure-pipelines)

8. **PublishBuildArtifacts@1:** Publishes files archived to the artifact staging directory in copy files stage to Azure Pipelines to make artifacts available for download. [Documentation on publishing an artifact to Azure Pipelines.](https://docs.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops&tabs=yaml-task)
      ```yaml 
        steps:
        - task: PublishPipelineArtifact@1
          inputs:
            targetPath: $(System.DefaultWorkingDirectory)/bin/myPath
            artifactName: drop
      ``` 
9. **NuGetCommand@2**: Publish artifacts as NuGet packages: 
  
  ```yaml
      - task: NuGetCommand@2
      displayName: 'NuGet pack'
      enabled: ${{ parameters.nugetPack }}
      inputs:
        command: pack
        versioningScheme: byPrereleaseNumber                            
        configuration: '${{ parameters.buildConfiguration }}'

    - task: NuGetCommand@2
      displayName: 'NuGet push'
      enabled: ${{ parameters.nugetPack }}
      publishVstsFeed: '${{ parameters.pushNugetFeed }}'
```
   Publishing an artifact as a NuGet package instead of as a pipeline artifact (or in addition to) can be done by enabling NuGet pack stage in your build template and providing a feed to push packages to: 

```yaml 
  parameters: 
     nugetPack: true
     publishVstsFeed: <feed>
```

Azure DevOps offers the following options for autoincremeting package versions: 
- byPrereleaseNumber (Date and time)
- byBuildNumber
- Custom (Provide env variable)

**Current default:** byPrereleaseNumber

Additional information on NuGet stages [is available in Microsoft documentation.](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/nuget?view=azure-devops&tabs=yaml) 

## How to Retain an Artifact after Publish to Azure Pipelines
By default, retention policies for artifacts set to publish to Azure Pipelines will be retained for as long as your build is retained (typically, a retention policy will be similar to `Last 3 runs will be retained`)
However, if a build artifact has been deployed or otherwise needs to be retained indefinitely, you can retain a specific build run: 
1. Select your desired pipeline in ADO portal.  
1. Click on `...` menu on righthand side to view and modify retention policies or retain a specific build. 

## Run Notifications
By default, the user triggering a manual pipeline run will recieve a notification of the run and its success or failure.  

In addition, notification for builds/deployments will be implemented by one of the following methods: 

- [Configure ADO email notification for selected actions](https://docs.microsoft.com/en-us/azure/devops/notifications/manage-team-group-global-organization-notifications?view=azure-devops&tabs=new-account-enabled&viewFallbackFrom=vsts)
- [Publishing build info to a Slack channel via ADO webhook](https://docs.microsoft.com/en-us/azure/devops/service-hooks/services/slack?view=azure-devops) 
- [Publishing build info to a Teams channel via ADO webhook](https://docs.microsoft.com/en-us/azure/devops/service-hooks/services/teams?view=azure-devops)

## Versions and Release Notes
**Latest release version:** v0.0.02

v0.0.01: First version of this pipeline as approved by xxxx dev team. 

v0.0.02: Parameterized version of v0.0.01. 
=========="===========
.net5orHigher

#v0.0.01 Custom Template Using DotnetCLI to build .NET >=5

parameters:
#Nuget and VSBuild Stage Parameters
- name: enableNugetRestore
  type: boolean
  default: true
- name: specifyDotnetVersion
  type: boolean
  default: false
- name: dotnetVersion
  type: string
  default: 3.x
- name: solution
  type: string
  default: "**/*.sln"
- name: publishProjects
  type: string
  default: "**/*.sln"
- name: buildPlatform
  default: ""
  type: string
- name: buildConfiguration
  default: "Release"
  type: string
- name: publishWebProjects
  type: boolean
  default: false
- name: vstsFeed
  type: string
  default: ""
- name: arguments
  type: string
- name: zipAfterPublish
  type: boolean
  default: true

# Optional - Copy contents to staging task for use if not using --output publish arg to copy files to artifact staging
- name: enableCopyContents
  displayName: "Enable or disable copy contents task"
  type: boolean
  default: false
- name: targetFolder
  type: string
  default: "$(build.artifactstagingdirectory)"
- name: copyContents
  type: string
  default: '**\bin\**'

# Publish artifact vars
- name: pathtopublish
  type: string
  default: "$(Build.ArtifactStagingDirectory)"
  # Enable or Disable NuGet Pack
- name: nugetPack
  type: boolean
  default: false
- name: nuGetFeedType
  type: string
  default: "internal"
- name: pushNugetFeed
  type: string
  default: ""
  #VSTest
- name: vsTestEnabled
  type: boolean
  default: true
  # Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'

- name: cxOneApplicationName
  default: ''
  type: string

- name: cxOneProjectGroup
  default: ''
  type: string

- name: checkmarxProjectName
  type: string
  default: ''
  #Publish artifact to Azure Pipelines
- name: enableArtifactPublish
  type: boolean
  default: true
- name: artifactName
  type: string
  default: "drop"
  #tests code coverage
- name: codeCoverageCollector
  type: string
  default: "XPlat Code Coverage"
- name: codeCoverageSummaryFile
  type: string
  default: "$(Agent.TempDirectory)/**/coverage.cobertura.xml"
  # Artifact
- name: zipArtifactName
  type: string
  default: "$(Build.Repository.Name)_$(Build.BuildId)"

- name: poolName
  type: string
  default: "Azure Pipelines"

jobs:
- job: "BuildPipeline"
  pool:
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace (replace(replace(variables['System.TeamProject'], '.', ' '),'BackOffice','Back Office'),'InternalWeb','Internal Web')]
  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}
  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}
  steps:
  - script: echo "appName is:" $(appName)
  - script: echo 'ProjectGroup =' $(projectGroup)
  - task: NuGetToolInstaller@1
    displayName: "NuGet tool install"

  - task: NuGetCommand@2
    enabled: ${{ parameters.enableNugetRestore }}
    displayName: "NuGet restore"
    inputs:
      restoreSolution: "${{ parameters.solution }}"
      vstsFeed: ${{ parameters.vstsFeed }}

  - task: UseDotNet@2
    displayName: "Use Specific .NET Core sdk"
    enabled: ${{ parameters.specifyDotnetVersion }}
    inputs:
      version: ${{ parameters.dotnetVersion }}

  # Add CxOne scan template before build
  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: '$(appName)'
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: DotNetCoreCLI@2
    displayName: Execute Unit Tests
    enabled: ${{ parameters.vsTestEnabled }}
    inputs:
      command: test
      projects: ${{ parameters.solution }}
      arguments: --configuration ${{ Parameters.buildConfiguration }} --collect:"${{ Parameters.codeCoverageCollector }}"

  - task: PublishCodeCoverageResults@2
    displayName: "Publish code coverage results"
    enabled: ${{ parameters.vsTestEnabled }}
    inputs:
      summaryFileLocation: "${{ Parameters.codeCoverageSummaryFile }}"

  - task: DotNetCoreCLI@2
    displayName: Publish Service
    inputs:
      command: "publish"
      publishWebProjects: ${{ parameters.publishWebProjects }}
      projects: ${{ parameters.publishProjects }}
      arguments: ${{ parameters.arguments }}
      zipAfterPublish: ${{ parameters.zipAfterPublish }}

  - task: PowerShell@2
    displayName: Rename Zip File
    enabled: ${{ Parameters.zipAfterPublish }}
    inputs:
      targetType: 'inline'
      script: |
        cd "$(Build.ArtifactStagingDirectory)"
        $sourcePath = Get-ChildItem -Path "$(Build.ArtifactStagingDirectory)" -Filter "*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $sourcePath
        $destinationPath = "${{ parameters.zipArtifactName }}.zip"
        Rename-Item -Path $sourcePath -NewName $destinationPath
        $destinationPath

  - task: CopyFiles@2
    displayName: "Copy Files to: $(build.artifactstagingdirectory)"
    enabled: ${{ parameters.enableCopyContents }}
    inputs:
      SourceFolder: "$(system.defaultworkingdirectory)"
      Contents: "${{ parameters.copyContents }}"
      TargetFolder: "${{ parameters.targetFolder }}"
      CleanTargetFolder: true
    condition: succeededOrFailed()

  - task: PublishBuildArtifacts@1
    enabled: ${{ parameters.enableArtifactPublish }}
    inputs:
      PathtoPublish: "${{ parameters.pathtopublish }}"
      ArtifactName: "${{ parameters.artifactName }}"
      publishLocation: "Container"

  - task: NuGetCommand@2
    displayName: "NuGet pack"
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: pack
      versioningScheme: byPrereleaseNumber
      configuration: "${{ parameters.buildConfiguration }}"

  - task: NuGetCommand@2
    displayName: "NuGet push"
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: push
      publishVstsFeed: "${{ parameters.pushNugetFeed }}"
=======================================================||
net6orHigher

#v0.0.06 Custom Template Using DotnetCLI to build .NET >=6
# Steps:
#   Checksout Self
#     Parameters:
#       None
#   Restore
#     Parameters:
#       RestoreBuildProjects: default: "**/**/*.csproj"
#   Use Specific .Net Core SDK
#       specifyDotnetVersion: default: false
#       dotnetVersion: default: 6.x
#   Build Projects
#     Paramters:
#       RestoreBuildProjects: used in Restore, same path for projects.
#       buildConfiguration: default: "Release"
#   Execute Unit Tests
#     Parameters:
#       TestsEnabled: default: true
#       TestProjects: default: "**/*[Tt]ests/*.csproj"
#       buildConfiguration: used in Build Projects and other places. Default: "Release"
#   Checkmarx Application Security Testing
#     Parameters:
#       checkmarxScanEnabled: default: true
#       checkmarxProjectName: Required.
#       enableProxy: default: false
#       enableSastScan: default: true
#       checkmarxServiceConnection: Required
#       preset: default: "High and Medium"
#       fullTeamName: Required
#       enableDependencyScan: default: false
#       vulnerabilityThreshold: default: true
#       failBuildForNewVulnerabilitiesEnabled: default: true
#       failBuildForNewVulnerabilitiesSeverity: default: MEDIUM
#   Publish
#     Parameters:
#       publishWebProjects: default: false
#       PublishProjects: default: "**/**/*.csproj"   #publishes all, restrict to get valid deployment artifacts
#       buildConfiguration:  used in Build Projects and other places. Default: "Release"
#       zipAfterPublish: default: true
#   Publish Artifacts
#     Parameters:
#       enableArtifactPublish: default: true
#       pathtopublish: default: "$(Build.ArtifactStagingDirectory)"
#       artifactName: default: "drop"

parameters:
- name: RestoreBuildProjects #Path to projects to use to Build/Restore.
  type: string
  default: "**/**/*.csproj"
- name: InternalNugetFeed # Feed to include internal Nuget libraries
  type: string
  default: ""
- name: nugetConfigPath # Path for optional nuget config file
  type: string
  default: ''
- name: TestProjects #Path/Pattern for Test projects to use for Test execution
  type: string
  default: "**/*[Tt]ests/*.csproj"
- name: TestsEnabled #Enable TEsts, Default is True
  type: boolean
  default: true
- name: PublishProjects #Project, usually singular to use to publish application
  type: string
  default: "**/**/*.csproj"

#Nuget and VSBuild Stage Parameters
- name: specifyDotnetVersion
  type: boolean
  default: false
- name: dotnetVersion
  type: string
  default: 6.x

# - name: buildPlatform
#   default: ""
#   type: string
- name: buildConfiguration
  default: "Release"
  type: string
- name: publishWebProjects
  type: boolean
  default: false
- name: zipAfterPublish
  type: boolean
  default: true
- name: pathtopublish
  type: string
  default: "$(Build.ArtifactStagingDirectory)"
  # Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'

- name: cxOneApplicationName
  default: ''
  type: string
- name: cxOneProjectGroup
  default: ''
  type: string

- name: checkmarxProjectName
  type: string
  default: ''
  # Publish artifact to Azure Pipelines
- name: enableArtifactPublish
  type: boolean
  default: true
- name: artifactName
  type: string
  default: "drop"
  # Enable or Disable NuGet Pack
- name: nugetPack
  type: boolean
  default: false
- name: nuGetFeedType
  type: string
  default: "internal"
- name: pushNugetFeed
  type: string
  default: ""
  # Specify Node js Version
- name: specifyNodeVersion
  type: boolean
  default: false
- name: nodeVersion
  type: string
  default: '18.x'
  #tests code coverage
- name: codeCoverageCollector
  type: string
  default: "XPlat Code Coverage"
- name: codeCoverageSummaryFile
  type: string
  default: "$(Agent.TempDirectory)/**/coverage.cobertura.xml"
  # Artifact
- name: zipArtifactName
  type: string
  default: "$(Build.Repository.Name)_$(Build.BuildId)"

# pool items
- name: poolName
  type: string
  default: "Azure Pipelines"

jobs:
- job: "BuildPipeline"
  pool:
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace (replace(replace(variables['System.TeamProject'], '.', ' '),'BackOffice','Back Office'),'InternalWeb','Internal Web')]

  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}
  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}

  steps:
  - checkout: self
    fetchDepth: 1
  - script: echo "appName is:" $(appName)
  - script: echo 'ProjectName ='  $(projectName)
  - script: echo 'ProjectGroup =' $(projectGroup)
  - task: NodeTool@0
    displayName: "Install Node.js ${{ parameters.nodeVersion }}"
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}
    condition: eq('${{ parameters.specifyNodeVersion }}', 'true')

  - task: DotNetCoreCLI@2
    displayName: Restore
    inputs:
      command: restore
      projects: ${{ Parameters.RestoreBuildProjects}}
      vstsFeed: ${{ Parameters.InternalNugetFeed }}
      includeNuGetOrg: true
      nugetConfigPath: ${{ Parameters.nugetConfigPath }}

  - task: UseDotNet@2
    displayName: "Use Specific .Net Core SDK"
    enabled: ${{ Parameters.specifyDotnetVersion }}
    inputs:
      version: ${{ Parameters.dotnetVersion }} #6.x

  # Replace existing Checkmarx One scan with template
  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: $(appName)
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: DotNetCoreCLI@2
    displayName: Build Projects
    inputs:
      projects: ${{ Parameters.RestoreBuildProjects }}
      arguments: --configuration ${{ Parameters.buildConfiguration }}

  - task: DotNetCoreCLI@2
    displayName: Execute Unit Tests
    enabled: ${{ Parameters.TestsEnabled }}
    inputs:
      command: test
      projects: ${{ Parameters.TestProjects }}
      arguments: --configuration ${{ Parameters.buildConfiguration }} --collect:"${{ Parameters.codeCoverageCollector }}"

  - task: PublishCodeCoverageResults@2
    displayName: "Publish code coverage results"
    enabled: ${{ Parameters.TestsEnabled }}
    inputs:
      summaryFileLocation: "${{ Parameters.codeCoverageSummaryFile }}"

  - task: DotNetCoreCLI@2
    displayName: Publish
    inputs:
      command: publish
      publishWebProjects: ${{ Parameters.publishWebProjects }}
      projects: ${{ Parameters.PublishProjects }}
      arguments: '--configuration ${{ Parameters.buildConfiguration}} --output ${{ Parameters.pathtopublish}}'
      zipAfterPublish: ${{ Parameters.zipAfterPublish }}

  - task: PowerShell@2
    displayName: Rename Zip File
    inputs:
      targetType: 'inline'
      script: |
        cd "${{ Parameters.pathtopublish }}"
        $sourcePath = Get-ChildItem -Path "${{ Parameters.pathtopublish }}" -Filter "*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $sourcePath
        $destinationPath = "${{ parameters.zipArtifactName }}.zip"
        Rename-Item -Path $sourcePath -NewName $destinationPath
        $destinationPath
    enabled: ${{ Parameters.zipAfterPublish }}

  - task: PublishBuildArtifacts@1
    displayName: Publish Artifact
    enabled: ${{ Parameters.enableArtifactPublish }}
    inputs:
      PathtoPublish: "${{ Parameters.pathtopublish }}"
      ArtifactName: "${{ Parameters.artifactName }}"
      publishLocation: "Container"

  - task: NuGetCommand@2
    displayName: "NuGet pack"
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: pack
      versioningScheme: byBuildNumber
      configuration: "${{ parameters.buildConfiguration }}"
      packagesToPack: ${{ Parameters.PublishProjects }}

  - task: NuGetCommand@2
    displayName: "NuGet push"
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: push
      publishVstsFeed: "${{ parameters.pushNugetFeed }}"
==================||=============
net8wpoooo

#v0.0.06 Custom Template Using DotnetCLI to build .NET >=6
# Steps:
#   Checksout Self
#     Parameters:
#       None
#   Restore
#     Parameters:
#       RestoreBuildProjects: default: "**/**/*.csproj"
#   Use Specific .Net Core SDK
#       specifyDotnetVersion: default: false
#       dotnetVersion: default: 8.x
#   Build Projects
#     Paramters:
#       RestoreBuildProjects: used in Restore, same path for projects.
#       buildConfiguration: default: "Release"
#   Execute Unit Tests
#     Parameters:
#       TestsEnabled: default: true
#       TestProjects: default: "**/*[Tt]ests/*.csproj"
#       buildConfiguration: used in Build Projects and other places. Default: "Release"
#   Checkmarx Application Security Testing
#     Parameters:
#       checkmarxScanEnabled: default: true
#       checkmarxProjectName: Required.
#       enableProxy: default: false
#       enableSastScan: default: true
#       checkmarxServiceConnection: Required
#       preset: default: "High and Medium"
#       fullTeamName: Required
#       enableDependencyScan: default: false
#       vulnerabilityThreshold: default: true
#       failBuildForNewVulnerabilitiesEnabled: default: true
#       failBuildForNewVulnerabilitiesSeverity: default: MEDIUM
#   Publish
#     Parameters:
#       publishWebProjects: default: false
#       PublishProjects: default: "**/**/*.csproj"   #publishes all, restrict to get valid deployment artifacts
#       buildConfiguration:  used in Build Projects and other places. Default: "Release"
#       zipAfterPublish: default: true
#   Publish Artifacts
#     Parameters:
#       enableArtifactPublish: default: true
#       pathtopublish: default: "$(Build.ArtifactStagingDirectory)"
#       artifactName: default: "drop"
#    Pool
#     Parameters:
#       poolName: default: "Azure Pipelines"

parameters:
- name: RestoreBuildProjects #Path to projects to use to Build/Restore.
  type: string
  default: "**/**/*.csproj"
- name: InternalNugetFeed # Feed to include internal Nuget libraries
  type: string
  default: ""
- name: nugetConfigPath # Path for optional nuget config file
  type: string
  default: ''
- name: TestProjects #Path/Pattern for Test projects to use for Test execution
  type: string
  default: "**/*[Tt]ests/*.csproj"
- name: TestsEnabled #Enable TEsts, Default is True
  type: boolean
  default: true
- name: PublishProjects #Project, usually singular to use to publish application
  type: string
  default: "**/**/*.csproj"

#Nuget and VSBuild Stage Parameters
- name: specifyDotnetVersion
  type: boolean
  default: false
- name: dotnetVersion
  type: string
  default: 8.x

# - name: buildPlatform
#   default: ""
#   type: string
- name: buildConfiguration
  default: "Release"
  type: string
- name: publishWebProjects
  type: boolean
  default: false
- name: zipAfterPublish
  type: boolean
  default: true
- name: pathtopublish
  type: string
  default: "$(Build.ArtifactStagingDirectory)"
  # Checkmarx One Scan
- name: checkmarxOneScanEnabled
  type: boolean
  default: true
- name: project-tags
  type: string
  default: ''
- name: threshold
  type: string
  default: 'sast-critical=1;sast-high=1;sast-medium=5;sast-low=15;sca-critical=1;sca-high=1;sca-medium=5;sca-low=15'
- name: file-include
  type: string
  default: ''
- name: sast-filter
  type: string
  default: '!**/test/**,!**/tests/**,!**/*.spec.*,!**/*.test.*,!**/node_modules/**,!**/bin/**,!**/obj/**,!**/dist/**,!**/build/**,!**/.git/**,!**/coverage/**'
- name: ignore-policy
  type: string
  default: ''
- name: sast-fast-scan
  type: string
  default: 'true'
- name: sast-incremental
  type: string
  default: 'true'
- name: sca-filter
  type: string
  default: '!*.svn,!*.dll,!*.git,!*.bzr,!**/bin/**,!**/obj/**,!**/node_modules/**'
- name: cxOneApplicationName
  default: ''
  type: string
- name: cxOneProjectGroup
  default: ''
  type: string
- name: checkmarxProjectName
  type: string
  default: ""
  # Publish artifact to Azure Pipelines
- name: enableArtifactPublish
  type: boolean
  default: true
- name: artifactName
  type: string
  default: "drop"
  # Enable or Disable NuGet Pack
- name: nugetPack
  type: boolean
  default: false
- name: nuGetFeedType
  type: string
  default: "internal"
- name: pushNugetFeed
  type: string
  default: ""
  # Specify Node js Version
- name: specifyNodeVersion
  type: boolean
  default: false
- name: nodeVersion
  type: string
  default: '18.x'
  #pool items
- name: poolName
  type: string
  default: "Azure Pipelines"
  #tests code coverage
- name: codeCoverageCollector
  type: string
  default: "XPlat Code Coverage"
- name: codeCoverageSummaryFile
  type: string
  default: "$(Agent.TempDirectory)/**/coverage.cobertura.xml"
  # Artifact
- name: zipArtifactName
  type: string
  default: "$(Build.Repository.Name)_$(Build.BuildId)"

jobs:
- job: "BuildPipeline"
  pool:
    displayName: "Executing on Pool ${{ parameters.nodeVersion }}"
    name: ${{ Parameters.poolName }}
    vmImage: "windows-latest"

  variables:
  - name: appNameDefault
    value: $[replace (replace(replace(variables['System.TeamProject'], '.', ' '),'BackOffice','Back Office'),'InternalWeb','Internal Web')]
  - ${{ if eq(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: $(appNameDefault)
  - ${{ if ne(parameters['cxOneApplicationName'], '') }}:
    - name: appName
      value: ${{ parameters['cxOneApplicationName'] }}
  - ${{ if eq(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: '$(Build.Repository.Name)'
  - ${{ if ne(parameters['checkmarxProjectName'], '') }}:
    - name: projectName
      value: ${{ parameters['checkmarxProjectName'] }}
  - ${{ if eq(variables['System.TeamProject'], 'BCOTools') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.AzureDevOps.Templates') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.Subversion.Archives') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxx.TFS.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Database') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS.Support.Other.Archive') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'xxxxS-Support') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'CAIT.LoanSampling') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Commercial.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Corporate Card Modernization') }}:
    - name: projectGroup
      value: CSS.HRDatamart
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.BAU') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Comm.Treasury') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Commercial.Other') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Compliance') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Consumer') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Enterprise') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.InternalWeb') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.Backoffice.Wealth.CavHill') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.TrustNet') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'DSG.BackOffice.Wealth.WSL') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'Filenet') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'Market Risk Management') }}:
    - name: projectGroup
      value: CxOne_RiskManagement
  - ${{ if eq(variables['System.TeamProject'], 'Mortgage') }}:
    - name: projectGroup
      value: CxOne_DSG_BackOffice
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.Archive') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.OpsDirector') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SQL') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'MTGSVCING.SSIS') }}:
    - name: projectGroup
      value: CxOne_MortgageServicing
  - ${{ if eq(variables['System.TeamProject'], 'REGIS') }}:
    - name: projectGroup
      value: CxOne_DSG_InternalWeb
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'SalesForce.Archive') }}:
    - name: projectGroup
      value: CxOne_SalesForce
  - ${{ if eq(variables['System.TeamProject'], 'WMS.International') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.OmniPlus') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if eq(variables['System.TeamProject'], 'WMS.Utilities') }}:
    - name: projectGroup
      value: CxOne_WMS
  - ${{ if ne(parameters['cxOneProjectGroup'], '') }}:
    - name: projectGroup
      value: ${{ parameters['cxOneProjectGroup'] }}
  steps:
  - script: echo "appName is:" $(appName)
  - script: echo 'ProjectGroup =' $(projectGroup)
  - checkout: self
    fetchDepth: 1

  - task: NodeTool@0
    displayName: "Install Node.js ${{ parameters.nodeVersion }}"
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}
    condition: eq('${{ parameters.specifyNodeVersion }}', 'true')

  - task: DotNetCoreCLI@2
    displayName: Restore
    inputs:
      command: restore
      projects: ${{ Parameters.RestoreBuildProjects}}
      vstsFeed: ${{ Parameters.InternalNugetFeed }}
      includeNuGetOrg: true
      nugetConfigPath: ${{ Parameters.nugetConfigPath }}

  - task: UseDotNet@2
    displayName: "Use Specific .Net Core SDK"
    enabled: ${{ Parameters.specifyDotnetVersion }}
    inputs:
      version: ${{ Parameters.dotnetVersion }}

  # New Checkmarx One Scan task. Will deprecated the old Checkmarx AST task eventually
  - template: /Build/Misc/CxOneScan.yml@core_templates
    parameters:
      cxOneScanEnabled: ${{ parameters.checkmarxOneScanEnabled }}
      project-tags: ${{ parameters['project-tags'] }}
      threshold: ${{ parameters.threshold }}
      file-include: ${{ parameters['file-include'] }}
      sast-filter: ${{ parameters['sast-filter'] }}
      ignore-policy: ${{ parameters['ignore-policy'] }}
      sast-fast-scan: ${{ parameters['sast-fast-scan'] }}
      sast-incremental: ${{ parameters['sast-incremental'] }}
      sca-filter: ${{ parameters['sca-filter'] }}
      application-name: $(appName)
      project-name: $(projectName)
      project-group: $(projectGroup)

  - task: DotNetCoreCLI@2
    displayName: Build Projects
    inputs:
      projects: ${{ Parameters.RestoreBuildProjects }}
      arguments: --configuration ${{ Parameters.buildConfiguration }}

  - task: DotNetCoreCLI@2
    displayName: Execute Unit Tests
    enabled: ${{ Parameters.TestsEnabled }}
    inputs:
      command: test
      projects: ${{ Parameters.TestProjects }}
      arguments: --configuration ${{ Parameters.buildConfiguration }} --collect:"${{ Parameters.codeCoverageCollector }}"

  - task: PublishCodeCoverageResults@2
    displayName: "Publish code coverage results"
    enabled: ${{ Parameters.TestsEnabled }}
    inputs:
      summaryFileLocation: "${{ Parameters.codeCoverageSummaryFile }}"

  - task: DotNetCoreCLI@2
    displayName: Publish
    inputs:
      command: publish
      publishWebProjects: ${{ Parameters.publishWebProjects }}
      projects: ${{ Parameters.PublishProjects }}
      arguments: '--configuration ${{ Parameters.buildConfiguration}} --output ${{ Parameters.pathtopublish}}'
      zipAfterPublish: ${{ Parameters.zipAfterPublish }}

  - task: PowerShell@2
    displayName: Rename Zip File
    inputs:
      targetType: 'inline'
      script: |
        cd "${{ Parameters.pathtopublish }}"
        $sourcePath = Get-ChildItem -Path "${{ Parameters.pathtopublish }}" -Filter "*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $sourcePath
        $destinationPath = "${{ parameters.zipArtifactName }}.zip"
        Rename-Item -Path $sourcePath -NewName $destinationPath
        $destinationPath
    enabled: ${{ Parameters.zipAfterPublish }}

  - task: PublishBuildArtifacts@1
    displayName: Publish Artifact
    enabled: ${{ Parameters.enableArtifactPublish }}
    inputs:
      PathtoPublish: "${{ Parameters.pathtopublish }}"
      ArtifactName: "${{ Parameters.artifactName }}"
      publishLocation: "Container"

  - task: NuGetCommand@2
    displayName: "NuGet pack"
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: pack
      versioningScheme: byBuildNumber
      configuration: "${{ parameters.buildConfiguration }}"
      packagesToPack: ${{ Parameters.PublishProjects }}

  - task: NuGetCommand@2
    displayName: "NuGet push"
    enabled: ${{ parameters.nugetPack }}
    inputs:
      command: push
      publishVstsFeed: "${{ parameters.pushNugetFeed }}"
------==================================
em.MD

# .NET >=4.9 Build Pipeline Template 
This directory contains versions of a build pipeline designed to build .NET applications using .NET 4.9 or above.  

**Latest release version:** 

High Level Overview:
 
This is a build pipeline that on manual run or a change pushed to the master branch of a repository will: 
- Request a Microsoft hosted agent with the ability to run this .NET framework build 
- Install NuGet and restore any requested packages 
- Publish 
- Copy required files from the working directory on the agent to the artifact staging directory 
- Run VSTest tests as configured
- Run Checkmarx preset and create report 
- Publish the files to Azure Pipelines as a downloadable zip 

Table of Contents: 
- [How to Use These Templates](#how-to-use-these-templates) 
- [Stages and options](#stages)
- [Versions and release notes](#versions-and-release-notes)

## How to Use These Templates 

Replace the following run variables: 

## Stages 

### Trigger 
This template is set up with a trigger to run automatically when changes are committed to the master branch of the repository: 

```yaml
trigger:
 branches:
   include:
    - master
```
To run this pipeline template for other branches of this repository, visit the pipeline in ADO interface and select "Run" > "Branch selection".  

**NOTE**: When running this pipeline from non-master branches, **the YAML pipeline file in the induvidual branch run will be the pipeline stages run.**  If updates are made to the azure-pipeline.yaml file in master branch, other branches must rebase to get those changes to their pipeline runs.  

### Agent Pool 

### Tasks 


## How to Manually Retain an Artifact after Publish to Azure Pipelines
By default, retention policies for artifacts set to publish to Azure Pipelines will be retained for as long as your build is retained (typically, a retention policy will be similar to `Last 3 runs will be retained`)
However, if a build artifact has been deployed or otherwise needs to be retained indefinitely, you can retain a specific build run: 
1. Select your desired pipeline in ADO portal.  
1. Click on `...` menu on righthand side to view and modify retention policies or retain a specific build. 

## Run Notifications
By default, the user triggering a manual pipeline run will recieve a notification of the run and its success or failure.  

In addition, notification for builds/deployments will be implemented by one of the following methods: 

- [Configure ADO email notification for selected actions](https://docs.microsoft.com/en-us/azure/devops/notifications/manage-team-group-global-organization-notifications?view=azure-devops&tabs=new-account-enabled&viewFallbackFrom=vsts)
- [Publishing build info to a Slack channel via ADO webhook](https://docs.microsoft.com/en-us/azure/devops/service-hooks/services/slack?view=azure-devops) 
- [Publishing build info to a Teams channel via ADO webhook](https://docs.microsoft.com/en-us/azure/devops/service-hooks/services/teams?view=azure-devops)

## Versions and Release Notes
**Latest release version:** 



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


