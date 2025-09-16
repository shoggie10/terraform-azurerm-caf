
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



# locals.tf
------------
https://meet.google.com/ihm-kyfu-wvu






# outputs.tf
----------





# examples.tf
-----------









===========||=========








----------------------------












======================================||=======================================================
======================================|\=======================================================
DotNetCoreBuild.yaml
---
# ASP.NET Core (.NET Core CLI)
# Build and test ASP.NET Core projects targeting the full .NET Core CLI.
# Add steps that publish symbols, save build artifacts, and more:
# https://docs.microsoft.com/azure/devops/pipelines/languages/dotnet-core

parameters:
  - name: DotNetCoreSdkVersion
    type: string
    default: ''
  - name: EnableDotNetCoreRestoreStep
    type: boolean
    default: true
  - name: EnableInstallNugetStep
    type: boolean
    default: false
  - name: NugetVersionSpec
    type: string
    default: ''
  - name: EnableNugetRestoreStep
    type: boolean
    default: false
  - name: SolutionFilePath
    type: string
    default: ''
  - name: NugetFeedsToUse
    type: string
    default: ''
  - name: NugetConfigPath
    type: string
    default: ''
  - name: VstsFeedId
    type: string
    default: ''
  - name: ProjectsToBuild
    type: string
    default: ''
  - name: EnableRunTestsStep
    type: boolean
    default: false
  - name: TestsProjectPath
    type: string
    default: ''
  - name: TestArguments
    type: string
    default: ''
  - name: EnablePublishProjectStep
    type: boolean
    default: false
  - name: ProjectsToPublish
    type: string
    default: ''
  - name: ZipAfterPublish
    type: string
    default: ''

steps:
  - task: UseDotNet@2
    displayName: "Use .Net Core ${{ parameters.DotNetCoreSdkVersion }} SDK"
    inputs:
      packageType: 'sdk'
      version: '${{ parameters.DotNetCoreSdkVersion }}'

  - task: DotNetCoreCLI@2
    displayName: "DotNetCore Restore"
    enabled: ${{ parameters.EnableDotNetCoreRestoreStep }}
    timeoutInMinutes: 30
    inputs:
      command: 'restore'
      projects: "${{ parameters.SolutionFilePath }}"
      feedsToUse: "${{ parameters.NugetFeedsToUse }}"
      nugetConfigPath: "${{ parameters.NugetConfigPath }}"
      vstsFeed: "${{ parameters.VstsFeedId }}"
      noCache: true

  - task: NuGetToolInstaller@1
    displayName: "Install NuGet"
    enabled: ${{ parameters.EnableInstallNugetStep }}
    inputs:
      versionSpec: "${{ parameters.NugetVersionSpec }}"

  - task: NuGetCommand@2
    displayName: "NuGet Restore"
    enabled: ${{ parameters.EnableNugetRestoreStep }}
    timeoutInMinutes: 30
    inputs:
      command: 'restore'
      restoreSolution: "${{ parameters.SolutionFilePath }}"
      feedsToUse: "${{ parameters.NugetFeedsToUse }}"
      nugetConfigPath: "${{ parameters.NugetConfigPath }}"
      vstsFeed: "${{ parameters.VstsFeedId }}"
      noCache: true

  - task: DotNetCoreCLI@2
    displayName: "Build Project"
    inputs:
      command: build
      projects: "${{ parameters.ProjectsToBuild }}"
      arguments: "--configuration Release -o $(Build.ArtifactStagingDirectory)"

  - task: DotNetCoreCLI@2
    displayName: "Run Tests"
    enabled: ${{ parameters.EnableRunTestsStep }}
    inputs:
      command: test
      projects: "${{ parameters.TestsProjectPath }}"
      arguments: "${{ parameters.TestArguments }}"

  - task: DotNetCoreCLI@2
    displayName: "Publish Project"
    enabled: ${{ parameters.EnablePublishProjectStep }}
    inputs:
      command: publish
      publishWebProjects: false
      projects: "${{ parameters.ProjectsToPublish }}"
      arguments: "--configuration Release -o $(Build.ArtifactStagingDirectory) --self-contained true --runtime win-x64"
      zipAfterPublish: "${{ parameters.ZipAfterPublish }}"
===========||=================
AngularBuild.yaml
----
# Build and Deploy Angular Applications.

parameters:
  - name: NodeJSVersion
    type: string
    default: ''
  - name: InstallNPMPackagesWorkingDirectory
    type: string
    default: ''
  - name: NPMBuildWorkingDirectory
    type: string
    default: ''
  - name: NPMBuildCommand
    type: string
    default: ''
  - name: EnableAngularTestsStep
    type: boolean
    default: false
  - name: NPMTestsWorkingDirectory
    type: string
    default: ''
  - name: NPMTestsCommand
    type: string
    default: ''
  - name: EnablePublishCodeCoverageResultsStep
    type: boolean
    default: false
  - name: CodeCoverageSummaryFileLocation
    type: string
    default: ''
  - name: CodeCoverageReportDirectory
    type: string
    default: ''
  - name: EnablePublishAngularTestResultsStep
    type: boolean
    default: false
  - name: AngularTestResultsFolder
    type: string
    default: ''
  - name: AngularTestRunTitle
    type: string
    default: ''
  - name: AngularTestResultsFormat
    type: string
    default: ''
  - name: AngularTestResultsFiles
    type: string
    default: ''
  - name: publishBuildArtifacts
    type: boolean
    default: false
  - name: zipPackage
    type: boolean
    default: false
  - name: artifactName
    type: string
    default: 'drop'
  - name: distPath
    type: string
    default: ''

steps:
  - task: NodeTool@0
    displayName: 'Install Node.js'
    inputs:
      versionSpec: '${{ parameters.NodeJSVersion }}'

  - task: Npm@1
    displayName: 'Install NPM Packages'
    inputs:
      command: 'install'
      workingDir: '${{ parameters.InstallNPMPackagesWorkingDirectory }}'

  - task: Npm@1
    displayName: 'Run NPM Build'
    inputs:
      command: 'custom'
      workingDir: '${{ parameters.NPMBuildWorkingDirectory }}'
      customCommand: '${{ parameters.NPMBuildCommand }}'

  - task: Npm@1
    displayName: 'Run Angular Tests'
    enabled: ${{ parameters.EnableAngularTestsStep }}
    inputs:
      command: 'custom'
      workingDir: '${{ parameters.NPMTestsWorkingDirectory }}'
      customCommand: '${{ parameters.NPMTestsCommand }}'

  - task: PublishCodeCoverageResults@1
    displayName: 'Publish Code Coverage Angular Results'
    enabled: ${{ parameters.EnablePublishCodeCoverageResultsStep }}
    inputs:
      codeCoverageTool: Cobertura
      summaryFileLocation: '${{ parameters.CodeCoverageSummaryFileLocation }}'
      reportDirectory: '${{ parameters.CodeCoverageReportDirectory }}'
      failIfCoverageEmpty: true

  - task: PublishTestResults@2
    displayName: 'Publish Angular Test Results'
    enabled: ${{ parameters.EnablePublishAngularTestResultsStep }}
    inputs:
      searchFolder: '${{ parameters.AngularTestResultsFolder }}'
      testRunTitle: '${{ parameters.AngularTestRunTitle }}'
      testResultsFormat: '${{ parameters.AngularTestResultsFormat }}'
      testResultsFiles: '${{ parameters.AngularTestResultsFiles }}'

  - task: CopyFiles@2
    displayName: "Copy Files to Folder"
    continueOnError: false
    timeoutInMinutes: 30
    inputs:
      SourceFolder: "${{ parameters.distPath }}"
      Contents: "**"
      TargetFolder: "$(Build.ArtifactStagingDirectory)"
      CleanTargetFolder: true
      OverWrite: true

  - task: ArchiveFiles@2
    displayName: Zip Package
    enabled: ${{ parameters.zipPackage }}
    inputs:
      rootFolderOrFile: "${{ parameters.distPath }}"
      includeRootFolder: false
      archiveType: "zip"
      archiveFile: "$(Build.ArtifactStagingDirectory)/${{ parameters.artifactName }}.zip"
      replaceExistingArchive: true

  - task: PublishPipelineArtifact@1
    displayName: "Upload Build Artifacts"
    enabled: ${{ parameters.publishBuildArtifacts }}
    inputs:
      targetPath: '$(Build.ArtifactStagingDirectory)' 
      artifactName: '${{ parameters.artifactName }}'
      artifactType: 'pipeline'
========||=====
SonarPrepare.yaml
---
# This template will Prepare SonarQube Analysis.

parameters:
  - name: ScannerMode
    type: string
    default: ''
  - name: ProjectKey
    type: string
    default: ''
  - name: ProjectName
    type: string
    default: ''
  - name: ExtraProperties
    type: string
    default: ''

steps:
  - task: SonarQubePrepare@5
    displayName: 'Prepare Analysis on SonarQube'
    condition: and(succeeded(),or(eq(variables['Build.SourceBranch'], 'refs/heads/master'), eq(variables['Build.SourceBranch'], 'refs/heads/main')))
    inputs:
      SonarQube: 'SonarQubeProd'
      scannerMode: "${{ parameters.ScannerMode }}"
      projectKey: "${{ parameters.ProjectKey }}"
      projectName: "${{ parameters.ProjectName }}"
      configMode: 'manual'
      cliProjectKey: "${{ parameters.ProjectKey }}"
      cliProjectName: "${{ parameters.ProjectName }}"
      cliProjectVersion: '$(Build.BuildNumber)'
      projectVersion: '$(Build.BuildNumber)'
      extraProperties: |
        # Additional properties that will be passed to the scanner, 
        # Put one key=value per line, example:
        sonar.verbose=true
        ${{ parameters.ExtraProperties }}
===========||=======
SonarRunPublishAnalysis.yaml
---
# This template will Run and Publish SonarQube Analysis.

steps:
  - task: SonarQubeAnalyze@4
    displayName: 'Run Analysis on SonarQube'
    condition: and(succeeded(),or(eq(variables['Build.SourceBranch'], 'refs/heads/master'), eq(variables['Build.SourceBranch'], 'refs/heads/main')))

  - task: SonarQubePublish@4
    displayName: 'Publish SonarQube Analysis Result'
    condition: and(succeeded(),or(eq(variables['Build.SourceBranch'], 'refs/heads/master'), eq(variables['Build.SourceBranch'], 'refs/heads/main')))
    inputs:
      pollingTimeoutSec: '300'

  =====================||========
jfrogBuildPromotionTemplate.yml
---
# template to promote artifacts from snapshots to releases repositories

parameters:
- name: targetRepo
  default: ''
- name: sourceRepo
  default: ''

steps:
- task: JFrogBuildPromotion@1
  inputs:
    artifactoryConnection: "jfrog-artifactory-production-azdoci"
    buildName: "$(Build.DefinitionName)"
    buildNumber: "$(Build.BuildNumber)"
    sourceRepo: "${{ parameters.sourceRepo }}"
    targetRepo: "${{ parameters.targetRepo }}"
    status: "Released"
    includeDependencies: false
    copy: true
    dryRun: false
=============||======
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

























































































