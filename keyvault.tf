
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
=====================||===================





=================||==================





build-d
===========||=========
- stage: BuildPushContainerImage
  displayName: Build, Scan & Push Image to Jfrog Artifactory
  dependsOn: Build_Project
  jobs:
  - job: Build_Container_Job
    displayName: Build Container Image
    pool: '$(buildAgentPoolName)'
    steps:
    - template: containers/build/azure-devops/templates/buildpushContainerImageTemplate.yml@templates   # Template reference
      parameters:
        artifactName: '$(buildArtifactName)' # Pipeline artifact containing build output
        imageName: '$(imageName)' # Name of image to be created
        imageRepositoryName: '$(imageRepositoryName)'
        workingDirectory: '$(System.DefaultWorkingDirectory)/src/xxxxx.DevOpsWeb' # Full path where the Dockerfile lives
        trivyTemplateFilePath: '$(System.DefaultWorkingDirectory)/Build/junit.tpl'
        serviceConnection: 'jfrog-artifactory-prod'







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
# templates/steps/jfrog-xray-buildscan.steps.yml
# Purpose: Step-level template to run a JFrog Xray Build Scan against a published Build-Info.
# Best practices:
#   - Ensure you have already run JFrogPublishBuildInfo@1 earlier in the job.
#   - Gate usage to protected branches, or fail builds on violations in release branches.
#   - Use a dedicated Xray (V2) service connection with least-privilege.
# Usage:
#   steps:
#   - template: templates/steps/jfrog-xray-buildscan.steps.yml
#     parameters:
#       xrayConnection: my-xray-connection
#       allowFailBuild: true
#       showVulnerabilities: false

parameters:
  # ---------------- Parameters (safe to override by callers) ----------------
  - name: xrayConnection           # Xray (V2) service connection name
    type: string
    default: "jfrog-xray-connection"
  - name: allowFailBuild           # Fail the job if policy violations are found
    type: boolean
    default: true
  - name: showVulnerabilities      # Optional: include vulnerability table in logs (may be noisy)
    type: boolean
    default: false

  # ---------------- Advanced (rarely changed) ----------------
  - name: buildName
    type: string
    default: "$(Build.DefinitionName)"
  - name: buildNumber
    type: string
    default: "$(Build.BuildNumber)"

steps:
  - task: JFrogBuildScan@1
    displayName: "JFrog Xray: Build Scan (Build=$(Build.DefinitionName) #$(Build.BuildNumber))"
    inputs:
      xrayConnection: "${{ parameters.xrayConnection }}"
      buildName: "${{ parameters.buildName }}"
      buildNumber: "${{ parameters.buildNumber }}"
      allowFailBuild: ${{ parameters.allowFailBuild }}
      vuln: ${{ parameters.showVulnerabilities }}
========||=====
# templates/steps/jfrog-xray-audit.steps.yml
# Purpose: Step-level template to run a JFrog Xray dependency audit using Watches / Project / Repo Path.
# Best practices:
#   - Use 'watches' for organization-wide policy enforcement.
#   - For app-scoped policies, you can target a projectKey or repoPath instead.
#   - Consider failing PRs on critical/high violations while allowing warnings on dev branches.
# Usage:
#   steps:
#   - template: templates/steps/jfrog-xray-audit.steps.yml
#     parameters:
#       xrayConnection: my-xray-connection
#       watchesSource: "watches"   # or project | repoPath
#       watches: "critical-watch,license-watch"
#       allowFailBuild: true

parameters:
  # ---------------- Parameters (policy selection) ----------------
  - name: xrayConnection           # Xray (V2) service connection name
    type: string
    default: "jfrog-xray-connection"
  - name: watchesSource            # 'watches' | 'project' | 'repoPath' | 'none'
    type: string
    default: "watches"
  - name: watches                  # Comma-separated watch names (if watchesSource == 'watches')
    type: string
    default: ""
  - name: projectKey               # Xray project key (if watchesSource == 'project')
    type: string
    default: ""
  - name: repoPath                 # <repo>/<path> (if watchesSource == 'repoPath')
    type: string
    default: ""
  - name: licenses                 # Include license compliance checks
    type: boolean
    default: true
  - name: allowFailBuild           # Fail the job on policy violations
    type: boolean
    default: true

steps:
  - task: JFrogAudit@1
    displayName: "JFrog Xray: Dependency Audit"
    inputs:
      xrayConnection: "${{ parameters.xrayConnection }}"
      watchesSource: "${{ parameters.watchesSource }}"
      watches: "${{ parameters.watches }}"
      projectKey: "${{ parameters.projectKey }}"
      repoPath: "${{ parameters.repoPath }}"
      licenses: ${{ parameters.licenses }}
      allowFailBuild: ${{ parameters.allowFailBuild }}
===========||=====
# azure-pipelines.steps-example.yml
# Demonstrates using *step templates* for:
#   1) Xray Build Scan
#   2) Xray Audit
#   3) JFrog Distribution
# Notes:
#   - Assumes you've already uploaded artifacts and published build-info earlier in this job/stage.
#   - Keep service connection names in variable group(s) or library (avoid hardcoding secrets).
#   - Consider branch-based conditions for fail behavior (stricter on main/release, softer on PRs).

trigger:
  branches:
    include: [ main, master, releases/* ]

# ---------------- Pipeline Parameters (clear separation) ----------------
parameters:
  # Agent / Pool
  - name: poolName
    type: string
    default: ""

  # Connections
  - name: xrayConnection
    type: string
    default: "jfrog-xray-connection"
  - name: distributionConnection
    type: string
    default: "jfrog-distribution-connection"

  # Release Bundle identity
  - name: rbName
    type: string
    default: "myReleaseBundle"
  - name: rbVersion
    type: string
    default: "$(Build.BuildNumber)"

  # Distribution rules example (JSON)
  - name: distRules
    type: string
    default: |
      { "distribution_rules": [ { "site_name": "*", "city_name": "*", "country_codes": ["*"] } ] }

pool:
  name: ${{ parameters.poolName }}

stages:
  - stage: Security_and_Distribution
    displayName: "Xray Scans & Distribution"
    jobs:
      - job: run_scans_and_distribute
        displayName: "Run Xray Build Scan, Audit, and Distribution"
        steps:
          # (Pre-req) Example: Ensure build-info is published before Build Scan
          # - task: JFrogPublishBuildInfo@1
          #   displayName: "Publish Artifactory Build Info"
          #   inputs:
          #     artifactoryConnection: "$(artifactoryConnection)"
          #     buildName: "$(Build.DefinitionName)"
          #     buildNumber: "$(Build.BuildNumber)"

          # ---------- 1) Xray Build Scan ----------
          - template: templates/steps/jfrog-xray-buildscan.steps.yml
            parameters:
              xrayConnection: ${{ parameters.xrayConnection }}
              allowFailBuild: true                   # fail on violations (recommended for release branches)
              showVulnerabilities: false             # toggle to true for verbose vuln table

          # ---------- 2) Xray Audit (Watches) ----------
          - template: templates/steps/jfrog-xray-audit.steps.yml
            parameters:
              xrayConnection: ${{ parameters.xrayConnection }}
              watchesSource: "watches"               # or 'project' / 'repoPath' (see template docs)
              watches: "critical-watch,license-watch"
              licenses: true
              allowFailBuild: true

          # ---------- 3) JFrog Distribution ----------
          # Create RB from precise AQL (recommended)
          - template: templates/steps/jfrog-distribution.steps.yml
            parameters:
              distributionConnection: ${{ parameters.distributionConnection }}
              command: "create"
              rbName: ${{ parameters.rbName }}
              rbVersion: ${{ parameters.rbVersion }}
              rbFileSpec: |
                {
                  "files": [
                    {
                      "aql": {
                        "query": {
                          "find": {
                            "repo": { "$eq": "libs-release-local" },
                            "path": { "$match": "org/system-id/my-app/*" }
                          }
                        }
                      }
                    }
                  ]
                }

          # Sign RB (required before distribute)
          - template: templates/steps/jfrog-distribution.steps.yml
            parameters:
              distributionConnection: ${{ parameters.distributionConnection }}
              command: "sign"
              rbName: ${{ parameters.rbName }}
              rbVersion: ${{ parameters.rbVersion }}

          # Distribute RB to edges
          - template: templates/steps/jfrog-distribution.steps.yml
            parameters:
              distributionConnection: ${{ parameters.distributionConnection }}
              command: "distribute"
              rbName: ${{ parameters.rbName }}
              rbVersion: ${{ parameters.rbVersion }}
              distRules: ${{ parameters.distRules }}
              distSync: true
              maxWaitSync: "60"


























































































