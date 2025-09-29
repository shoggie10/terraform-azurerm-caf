
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

# build-test-scan-job-templates
------------
# DevSecOps Job Template (Universal)
# Usage example:
# - template: devsecops-job.universal.yaml
#   parameters:
#     jobName: 'DevSecOps'
#     sonarQubeConnection: 'SonarQubeServer'
#     sonarQubeProject: 'my-project-key'
#     # ... other params as needed


# Build, Test, Scan, and Analyze Stage Template (Refactored: Baseline + Options)
# - Baseline on: Gitleaks, ONE dependency scanner (choose), SonarQube, tests/coverage, notifications
# - Optional: second dependency scanner, Advanced Dep Scan, Checkmarx, OWASP JUnit publishing

parameters:
# ---------- Job naming / display ----------
- name: jobName
  type: string
  default: 'Build_Test_Scan_Analyze_Job'
- name: displayName
  type: string
  default: 'App'
- name: projectName
  type: string
  default: 'SampleProject'
- name: notificationStageDisplay
  type: string
  default: 'Build, Test, Scan & Analyze'

# ---------- Build / restore ----------
- name: dotnetSdkVersion
  type: string
  default: '8.0.x'
- name: buildConfiguration
  type: string
  default: 'Release'
- name: projectsPattern
  type: string
  default: '**/*.csproj'
- name: restoreExtraArgs
  type: string
  default: ''
- name: buildExtraArgs
  type: string
  default: ''

# Optional NuGet auth
- name: nugetServiceConnection
  type: string
  default: ''

# ---------- Paths / directories ----------
- name: testResultsDir
  type: string
  default: '$(Agent.TempDirectory)/tests'
- name: securityReportsDir
  type: string
  default: '$(Agent.TempDirectory)/security'

# ---------- SonarQube ----------
- name: sonarQubeProject
  type: string
  default: ''
- name: sonarQubeConnection
  type: string
  default: ''
- name: sonarPollingTimeoutSec
  type: string
  default: '300'
- name: sonarExtraProperties
  type: string
  default: ''  # Multiline sonar.* properties if needed

# ---------- Secrets scanning (GitLeaks) ----------
- name: enableSecretScanning
  type: boolean
  default: true
- name: secretScanningTool
  type: string
  values: [gitleaks]
  default: gitleaks
- name: gitleaksConfigType
  type: string
  values: [default, predefined, custom]
  default: default
- name: gitleaksConfigPath
  type: string
  default: ''  # Only used when config type is custom
- name: gitleaksScanMode
  type: string
  values: [directory, git]
  default: directory
- name: gitleaksReportDir
  type: string
  default: '$(Agent.TempDirectory)/gitleaks'
- name: gitleaksArtifactName
  type: string
  default: 'CodeAnalysisLogs'
- name: gitleaksTaskFail
  type: boolean
  default: false  # prefer warnings by default

# ---------- Dependency scanning (OWASP / Xray / Advanced) ----------
- name: dependencyScanner
  type: string
  values: [owasp, xray, both, none]
  default: owasp

# OWASP
- name: enableOwaspDependencyCheck
  type: boolean
  default: true
- name: owaspScanPath
  type: string
  default: '$(Build.SourcesDirectory)'
- name: owaspFailOnCvss
  type: string
  default: '7'
- name: owaspEnableRetired
  type: boolean
  default: true
- name: owaspEnableExperimental
  type: boolean
  default: true
- name: owaspSuppressionPath
  type: string
  default: 'owasp-suppressions.xml'
- name: owaspFormat
  type: string
  values: [SARIF, JUNIT, ALL]
  default: SARIF
- name: publishOwaspToTestsTab
  type: boolean
  default: false
- name: owaspSarifPath
  type: string
  default: '$(Build.SourcesDirectory)/dependency-check-report.sarif'

# Xray
- name: enableJFrogScan
  type: boolean
  default: false
- name: xrayConnection
  type: string
  default: ''
- name: xrayWatchesSource
  type: string
  values: [all, project, none]
  default: all
- name: xrayIncludeLicenses
  type: boolean
  default: false
- name: xrayOutputDir
  type: string
  default: '$(Agent.TempDirectory)/xray-audit'

# Advanced dependency scanner (optional product)
- name: enableAdvancedDepScan
  type: boolean
  default: false

# ---------- Tests & coverage ----------
- name: runUnitTests
  type: boolean
  default: true
- name: unitTestPattern
  type: string
  default: '**/*[Tt]ests.[Uu]nit/*.csproj'
- name: runIntegrationTests
  type: boolean
  default: false
- name: integrationTestPattern
  type: string
  default: '**/*[Tt]ests.[Ii]ntegration/*.csproj'
- name: runCodeCoverage
  type: boolean
  default: true
- name: generateTestReports
  type: boolean
  default: true
- name: coverageTool
  type: string
  values: [Cobertura, JaCoCo]
  default: Cobertura

# ---------- Notifications ----------
- name: enableTeams
  type: boolean
  default: false
- name: teamsWebhookUrl
  type: string
  default: ''
- name: enableSlack
  type: boolean
  default: false
- name: slackWebhookUrl
  type: string
  default: ''
- name: emailRecipients
  type: string
  default: ''
- name: notificationType
  type: string
  values: [success, failure, both]
  default: both

jobs:
- job: ${{ parameters.jobName }}
  displayName: '${{ parameters.notificationStageDisplay }} Job'
  variables:
    testResultsPath: '${{ parameters.testResultsDir }}'
    securityReportsPath: '${{ parameters.securityReportsDir }}'
  steps:
    # .NET SDK
    # Setup .NET SDK environment for building the application
    - task: UseDotNet@2
      displayName: '🔧 Install .NET SDK'
      inputs:
        version: ${{ parameters.dotnetSdkVersion }}
        performMultiLevelLookup: true

    # Authenticate with NuGet package feed for secure package access
    - ${{ if ne(parameters.nugetServiceConnection, '') }}:
      - task: NuGetAuthenticate@1
        displayName: '🔐 NuGet Authenticate'
        inputs:
          nuGetServiceConnections: '${{ parameters.nugetServiceConnection }}'

    # ===== Secrets scanning: GitLeaks =====
    - ${{ if and(eq(parameters.enableSecretScanning, true), eq(parameters.secretScanningTool, 'gitleaks')) }}:
      - task: Gitleaks@3
        displayName: '🔑 GitLeaks Secret Scanning'
        inputs:
          scanlocation: '$(Build.SourcesDirectory)'
          configtype: '${{ parameters.gitleaksConfigType }}'    # or 'predefined' with predefinedconfigfile
          # Only used if custom:
          # configfile: '${{ parameters.gitleaksConfigPath }}'
          reportformat: 'sarif'
          reportfolder: '${{ parameters.gitleaksReportDir }}'   # <-- fixed name
          verbose: true
          redact: true
          # Recommended extras:
          uploadresults: true
          reportartifactname: '${{ parameters.gitleaksArtifactName }}'
          scanmode: '${{ parameters.gitleaksScanMode }}'  # use if not fetching full history
          taskfail: ${{ parameters.gitleaksTaskFail }}    # set true if you want to fail on findings

      # ===== Dependency scanning (choose one/both/none) =====
      # OWASP Dependency-Check
    - ${{ if or(eq(parameters.dependencyScanner, 'owasp'), eq(parameters.dependencyScanner, 'both')) }}:
      - ${{ if eq(parameters.enableOwaspDependencyCheck, true) }}:
        - task: dependency-check-build-task@6
          displayName: '🧬 OWASP Dependency Check'
          continueOnError: true
          inputs:
            projectName: '${{ parameters.displayName }}'
            scanPath: '${{ parameters.owaspScanPath }}'   # e.g. '$(Build.SourcesDirectory)', **/*.csproj
            format: '${{ parameters.owaspFormat }}'       # HTML, XML, JSON, SARIF, or ALL
            additionalArguments: |
              ${{ if eq(parameters.owaspEnableRetired, true) }}--enableRetired
              ${{ if eq(parameters.owaspEnableExperimental, true) }}--enableExperimental
              --failOnCVSS ${{ parameters.owaspFailOnCvss }}
            suppressionPath: '${{ parameters.owaspSuppressionPath }}'   # Optional: specify if you have suppressions file


        # Prefer SARIF → Scans tab. If JUnit desired, publish tests too.
        # Publish OWASP vulnerability results to Azure DevOps
        - ${{ if eq(parameters.publishOwaspToTestsTab, true) }}:
          - task: PublishTestResults@2
            displayName: 'Publish OWASP (JUnit)'
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/dependency-check-junit.xml'
              testRunTitle: 'OWASP Dependency Check'
              mergeTestResults: true
              failTaskOnFailedTests: false

        # This is the preferred way if you want DevSecOps-style vulnerability surfacing in ADO.
        - ${{ if or(eq(parameters.owaspFormat, 'SARIF'), eq(parameters.owaspFormat, 'ALL')) }}:
          - task: PublishBuildArtifacts@1
            displayName: 'Publish OWASP SARIF to Scans'
            inputs:
              pathToPublish: '${{ parameters.owaspSarifPath }}'
              artifactName: 'CodeAnalysisLogs'
            condition: always()

    # ===== Dependency scanning: JFrog Xray =====
    # Perform JFrog Xray security scan for dependency 
    - ${{ if or(eq(parameters.dependencyScanner, 'xray'), eq(parameters.dependencyScanner, 'both')) }}:
      - ${{ if and(eq(parameters.enableJFrogScan, true), ne(parameters.xrayConnection, '')) }}:
        - task: JFrogAudit@1
          displayName: 'JFrog Xray Audit'
          inputs:
            xrayConnection: '${{ parameters.xrayConnection }}'
            watchesSource: '${{ parameters.xrayWatchesSource }}'   # all | project | none
            licenses: ${{ parameters.xrayIncludeLicenses }}        # include license violations?

        - task: PublishBuildArtifacts@1
          displayName: 'Publish Xray Audit Outputs'
          continueOnError: true
          inputs:
            pathToPublish: '${{ parameters.xrayOutputDir }}'   # <-- adjust to your report path
            artifactName: 'xray-audit'
          condition: always()

    # ===== SonarQube Prepare =====
    # Prepare SonarQube server for code quality and security analysis
    # --- SonarQube: Prepare → Build/Test → Analyze → Publish ---
    # Requires a Service Connection named in `sonarQubeConnection`
    # and a project key/name in `sonarQubeProject`.
    - ${{ if and(ne(parameters.sonarQubeConnection, ''), ne(parameters.sonarQubeProject, '')) }}:
      - task: SonarQubePrepare@7
        displayName: 'Prepare SonarQube analysis'
        inputs:
          SonarQube: ${{ parameters.sonarQubeConnection }} # service connection name
          ScannerMode: 'MSBuild'
          ProjectKey: ${{ parameters.sonarQubeProject }}
          ProjectName: ${{ parameters.sonarQubeProject }}
          ${{ if ne(parameters.sonarExtraProperties, '') }}:
            ExtraProperties: |
              ${{ parameters.sonarExtraProperties }}
          # Optional: extra settings (uncomment as needed)
          # ExtraProperties: |
          #   sonar.cs.opencover.reportsPaths=$(Build.SourcesDirectory)/**/coverage.opencover.xml
          #   sonar.coverage.exclusions=**/*Tests/*.cs

    # ===== Restore / Build =====
    - task: DotNetCoreCLI@2
      displayName: 'Restore Dependencie'
      inputs:
        command: restore
        projects: '${{ parameters.projectsPattern }}'   #'**/*.csproj'
        ${{ if ne(parameters.restoreExtraArgs, '') }}:
          arguments: '${{ parameters.restoreExtraArgs }}'

    - task: DotNetCoreCLI@2
      displayName: 'Build ${{ parameters.displayName }}'
      inputs:
        command: build
        projects: '${{ parameters.projectsPattern }}'
        arguments: >
          --configuration ${{ parameters.buildConfiguration }}
          ${{ parameters.buildExtraArgs }}

    # ===== Tests =====
    # Unit Tests (conditional)
    - ${{ if eq(parameters.runUnitTests, true) }}:
      - task: DotNetCoreCLI@2
        displayName: 'Execute Unit Tests'
        inputs:
          command: test
          projects: ${{ parameters.unitTestPattern }}
          publishTestResults: ${{ parameters.generateTestReports }}
          testRunTitle: 'Unit Tests'
          arguments: >
            --configuration ${{ parameters.buildConfiguration }}
            --no-build --verbosity normal
            --logger "trx;LogFileName=unit.trx"
            --results-directory "${{ parameters.testResultsDir }}/unit"

    # Integration Tests (conditional)
    - ${{ if eq(parameters.runIntegrationTests, true) }}:
      - task: DotNetCoreCLI@2
        displayName: 'Execute Integration Tests'
        inputs:
          command: test
          projects: ${{ parameters.integrationTestPattern }}
          publishTestResults: ${{ parameters.generateTestReports }}
          testRunTitle: 'Integration Tests'
          arguments: >
            --configuration ${{ parameters.buildConfiguration }}
            --no-build --verbosity normal
            --logger "trx;LogFileName=integration.trx"
            --results-directory "${{ parameters.testResultsDir }}/integration"

    # ===== Coverage =====
    # Coverage collection & publish
    - ${{ if and(eq(parameters.runUnitTests, true), eq(parameters.runCodeCoverage, true)) }}:
      - task: DotNetCoreCLI@2
        displayName: 'Collect Coverage (XPlat)'
        inputs:
          command: test
          projects: ${{ parameters.unitTestPattern }}
          publishTestResults: false
          testRunTitle: 'Unit Tests Coverage'
          arguments: >
            --configuration ${{ parameters.buildConfiguration }}
            --no-build
            --collect "XPlat Code Coverage"
            --results-directory "${{ parameters.testResultsDir }}/coverage"

      - task: PublishCodeCoverageResults@2
        displayName: 'Publish Coverage (Cobertura)'
        inputs:
          codeCoverageTool: '${{ parameters.coverageTool }}'
          summaryFileLocation: '${{ parameters.testResultsDir }}/coverage/**/coverage.cobertura.xml'
          reportDirectory: '${{ parameters.testResultsDir }}/coverage'
          failIfCoverageEmpty: false

    # ===== Optional: Advanced Dependency Scanning product =====
    # For the most accurate scanning results, add the Advanced Security dependency scanning task after your build steps but before 
    # any clean up of the build process, as shown in the following example.
    # Run dependency scanning 
    - ${{ if eq(parameters.enableAdvancedDepScan, true) }}:
      - task: AdvancedSecurity-Dependency-Scanning@1 
        displayName: 'Advanced Security Dependency Scanning'

    # ===== SonarQube Analyze + Publish (if prepared) =====
    # Run SonarQube analysis for code quality metrics and upload the results to the SonarQube server. This task isn't required for Maven or Gradle projects. 
    # For Java, analyzing your source code is also very easy. It only requires adding the Prepare Analysis Configuration task and checking the Run SonarQube 
    # (Server, Cloud) Analysis option in the 'Code Analysis' panel in your Maven or Gradle task.
    - ${{ if and(ne(parameters.sonarQubeConnection, ''), ne(parameters.sonarQubeProject, '')) }}:
      - task: SonarQubeAnalyze@7
        displayName: '🔎 Run SonarQube analysis'
        # inputs:
        #   jdkversion: 'JAVA_HOME_17_X64' # 'JAVA_HOME' | 'JAVA_HOME_17_X64' | 'JAVA_HOME_21_X64'. Required. JDK version source for analysis. Default: JAVA_HOME_17_X64.
        
      - task: SonarQubePublish@7
        displayName: '📤 Publish SonarQube quality gate'
        inputs:
          pollingTimeoutSec: '${{ parameters.sonarPollingTimeoutSec }}'

    # # Execute Checkmarx SAST for static application security testing
    # # SAST (Checkmarx) – after code is built and tested, scans full source
    # - task: CheckmarxCxFlow@1
    #   displayName: "🔍 Checkmarx SAST Code Scan"
    #   continueOnError: true
    #   inputs:
    #     checkmarxService: "${{ parameters.checkmarxConnection }}"
    #     projectName: "${{ parameters.checkmarxProject }}"
    #     teamName: "CxServer"
    #     preset: "Checkmarx Default"
    #     incremental: false
    #     vulnerabilityThreshold: true
    #     high: 0
    #     medium: 0
    #     low: 0
    #     enablePolicyViolations: false
    #     enableSynchronousMode: true
    #     generateReportPDF: true


    # ===== Notifications =====
    - template: notification-step.yaml
      parameters:
        notificationType: '${{ parameters.notificationType }}'
        stageName: '${{ parameters.notificationStageDisplay }}'
        projectName: '${{ parameters.projectName }}'
        enableTeams: ${{ parameters.enableTeams }}
        teamsWebhookUrl: '${{ parameters.teamsWebhookUrl }}'
        enableSlack: ${{ parameters.enableSlack }}
        slackWebhookUrl: '${{ parameters.slackWebhookUrl }}'
        enableEmail: ${{ ne(parameters.emailRecipients, '') }}
        emailRecipients: '${{ parameters.emailRecipients }}'








# build-docker-image-job.acr-template.yaml
----------
# Docker Build & Push Job Template (Lean ACR Version)
# This version only targets Azure Container Registry (ACR) with optional Trivy scan.

parameters:
  # ---------- Job Naming ----------
  - name: jobName
    type: string
    default: 'Build_Push_ACR_Job'
  - name: jobDisplayName
    type: string
    default: 'Build & Push Docker Image (ACR)'

  # ---------- Build Inputs ----------
  - name: artifactName
    type: string
    default: 'drop'
  - name: dockerfilePath
    type: string
    default: 'Dockerfile'
  - name: workingDirectory
    type: string
    default: '.'
  - name: imageName
    type: string
    default: ''
  - name: imageRepository
    type: string
    default: ''
  - name: imageTags
    type: string
    default: '$(Build.BuildNumber)'

  # ---------- Registry ----------
  - name: containerRegistry
    type: string
    default: ''

  # ---------- Service connection ----------
  - name: serviceConnection
    type: string
    default: ''

  # ---------- Debugging & Tag Strategy ----------
  - name: enableDebugging
    type: boolean
    default: false

  # ---------- Security Scanning ----------
  - name: trivyTemplateFilePath
    type: string
    default: 'pipelines/build/azure-devops/junit.tpl'

  # ---------- MutliArch Option ----------
  - name: enableMultiArch
    type: boolean
    default: false
  - name: targetPlatforms
    type: string
    default: 'linux/amd64,linux/arm64'

jobs:
- job: ${{ parameters.jobName }}
  displayName: ${{ parameters.jobDisplayName }}
  pool:
    vmImage: 'ubuntu-latest'

  steps:
    # Download build artifacts
    - task: DownloadPipelineArtifact@2
      displayName: "Download Build Artifact - ${{ parameters.artifactName }}"
      inputs:
        source: 'current'
        artifact: '${{ parameters.artifactName }}'
        path: '$(Pipeline.Workspace)/${{ parameters.artifactName }}'

    # Extract binaries if zipped
    - task: ExtractFiles@1
      displayName: "Extract App Binaries"
      inputs:
        archiveFilePatterns: '$(Pipeline.Workspace)/${{ parameters.artifactName }}/*.zip'
        destinationFolder: '${{ parameters.workingDirectory }}/publish'
        cleanDestinationFolder: false
        overwriteExistingFiles: false

    # Debugging
    - ${{ if eq(parameters.enableDebugging, true) }}:
      - bash: docker images --all
        displayName: List Docker Images
        failOnStderr: false

    # Log into ACR
    - task: Docker@2
      displayName: '🔐 Log into ACR'
      inputs:
        command: login
        containerRegistry: ${{ parameters.containerRegistryService }}

    # # Build Docker image
    # - task: Docker@2
    #   displayName: "🐳 Build Docker Image"
    #   inputs:
    #     command: build
    #     repository: ${{ parameters.imageName }}
    #     dockerfile: ${{ parameters.dockerfilePath }}
    #     buildContext: ${{ parameters.workingDirectory }}
    #     tags: |
    #       ${{ parameters.imageTags }}

    # Docker build (single or multi-arch)
    - ${{ if eq(parameters.enableMultiArch, false) }}:
      - task: Docker@2
        displayName: "Build Docker Image (Single Arch)"
        inputs:
          command: build
          repository: ${{ parameters.imageName }}
          dockerfile: ${{ parameters.dockerfilePath }}
          buildContext: ${{ parameters.workingDirectory }}
          tags: |
            ${{ parameters.imageTags }}

    - ${{ if eq(parameters.enableMultiArch, true) }}:
      - script: |
          echo "🔧 Enabling experimental Docker Buildx"
          docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
          docker buildx create --use --name multiarchbuilder
          docker buildx inspect --bootstrap
          docker buildx build             --platform ${{ parameters.targetPlatforms }}             -t ${{ parameters.imageRepository }}/${{ parameters.imageName }}:${{ parameters.imageTags }}             -f ${{ parameters.dockerfilePath }}             ${{ parameters.workingDirectory }}             --push
        displayName: "Build & Push Docker Image (Multi Arch)"

    # Inspect the image
    - bash: |
        docker image inspect ${{ parameters.imageName }}:$(Build.BuildNumber)
      displayName: Show Details of the Docker Image
      failOnStderr: false

    # Install Trivy
    - script: |
        LATEST_VERSION=($(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest           | awk '/tag_name/ {print $2}' | cut -d '"' -f 2 | cut -d 'v' -f 2))
        sudo apt-get install -y rpm
        wget https://github.com/aquasecurity/trivy/releases/download/v${LATEST_VERSION}/trivy_${LATEST_VERSION}_Linux-64bit.deb
        sudo dpkg -i trivy_${LATEST_VERSION}_Linux-64bit.deb
        trivy -v
      displayName: Download and Install Latest Trivy

    # Scan image with Trivy
    - task: CmdLine@2
      displayName: Scan the Image with Trivy CLI
      name: scanVariables
      inputs:
        script: |
          cd $(Build.SourcesDirectory)
          trivy image --exit-code 0 --severity LOW,MEDIUM             --format template --template "@${{ parameters.trivyTemplateFilePath }}"             -o junit-report-low-med.xml ${{ parameters.imageRepository }}/${{ parameters.imageName }}:$(Build.BuildNumber)
          trivy image --exit-code 1 --severity HIGH,CRITICAL             --format template --template "@${{ parameters.trivyTemplateFilePath }}"             -o junit-report-high-crit.xml ${{ parameters.imageRepository }}/${{ parameters.imageName }}:$(Build.BuildNumber)
          echo "##vso[task.setvariable variable=TrivyScanResults;isOutput=true;]$?"

    # Publish Trivy results
    - task: PublishTestResults@2
      displayName: Capture Low and Medium Vulnerabilities
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/junit-report-low-med.xml'
        mergeTestResults: true
        failTaskOnFailedTests: false
        testRunTitle: 'Trivy Scan - Low/Medium'
      condition: 'always()'

    - task: PublishTestResults@2
      displayName: Capture High and Critical Vulnerabilities
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/junit-report-high-crit.xml'
        mergeTestResults: true
        failTaskOnFailedTests: false
        testRunTitle: 'Trivy Scan - High/Critical'
      condition: 'always()'

    # Push Docker image to ACR
    - task: Docker@2
      displayName: "🚀 Push Docker Image to ACR"
      inputs:
        command: push
        containerRegistry: ${{ parameters.containerRegistryService }}
        repository: ${{ parameters.imageName }}
        tags: |
          ${{ parameters.imageTags }}





# build-docker-image-job.jfrog-template.yaml
-----------
# Docker Build & Push Job Template (Enterprise JFrog - Corrected & Aligned with ACR)
# Includes artifact extraction, Docker build, inspect, Trivy install & scan, push to JFrog, and build info publishing.

parameters:
  # ---------- Job Naming ----------
  - name: jobName
    type: string
    default: 'Build_Push_JFrog_Job'
  - name: jobDisplayName
    type: string
    default: 'Build & Push Docker Image (Enterprise JFrog)'

 # ---------- Build Inputs ----------
  - name: artifactName
    type: string
    default: 'drop'
  - name: dockerfilePath
    type: string
    default: 'Dockerfile'
  - name: workingDirectory
    type: string
    default: '.'
  - name: imageName
    type: string
    default: ''
  - name: imageRepositoryName
    type: string
    default: ''
  - name: imageTags
    type: string
    default: '$(Build.BuildNumber)'

  # ---------- Registry ----------
  - name: containerRegistry
    type: string
    default: ''

  # ---------- Service connection ----------
  - name: serviceConnection
    type: string
    default: ''

  # ---------- Debugging & Tag Strategy ----------
  - name: enableDebugging
    type: boolean
    default: false

  # ---------- Security Scanning ----------
  - name: trivyTemplateFilePath
    type: string
    default: 'pipelines/build/azure-devops/junit.tpl'

  # ---------- MutliArch Option ----------
  - name: enableMultiArch
    type: boolean
    default: false
  - name: targetPlatforms
    type: string
    default: 'linux/amd64,linux/arm64'

jobs:
- job: ${{ parameters.jobName }}
  displayName: ${{ parameters.jobDisplayName }}
  pool:
    vmImage: 'ubuntu-latest'

  steps:
    # Download build artifacts
    - task: DownloadPipelineArtifact@2
      displayName: "Download Build Artifact - ${{ parameters.artifactName }}"
      inputs:
        source: 'current'
        artifact: '${{ parameters.artifactName }}'
        path: '$(Pipeline.Workspace)/${{ parameters.artifactName }}'

    # Extract binaries if zipped
    - task: ExtractFiles@1
      displayName: "Extract App Binaries"
      inputs:
        archiveFilePatterns: '$(Pipeline.Workspace)/${{ parameters.artifactName }}/*.zip'
        destinationFolder: '${{ parameters.workingDirectory }}/publish'
        cleanDestinationFolder: false
        overwriteExistingFiles: false

    # Debugging
    - ${{ if eq(parameters.enableDebugging, true) }}:
      - bash: docker images --all
        displayName: List Docker Images
        failOnStderr: false

    # # Docker build
    # - task: Docker@2
    #   displayName: "🐳 Build Docker Image"
    #   inputs:
    #     command: build
    #     repository: ${{ parameters.imageName }}
    #     dockerfile: ${{ parameters.dockerfilePath }}
    #     buildContext: ${{ parameters.workingDirectory }}
    #     tags: |
    #       ${{ parameters.imageTags }}

    # Docker build (single or multi-arch)
    - ${{ if eq(parameters.enableMultiArch, false) }}:
      - task: Docker@2
        displayName: "🐳 Build Docker Image (Single Arch)"
        inputs:
          command: build
          repository: ${{ parameters.imageName }}
          dockerfile: ${{ parameters.dockerfilePath }}
          buildContext: ${{ parameters.workingDirectory }}
          tags: |
            ${{ parameters.imageTags }}

    - ${{ if eq(parameters.enableMultiArch, true) }}:
      - script: |
          echo "🔧 Enabling experimental Docker Buildx"
          docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
          docker buildx create --use --name multiarchbuilder
          docker buildx inspect --bootstrap
          docker buildx build             --platform ${{ parameters.targetPlatforms }}             -t ${{ parameters.containerRegistry }}/${{ parameters.imageRepositoryName }}/${{ parameters.imageName }}:${{ parameters.imageTags }}             -f ${{ parameters.dockerfilePath }}             ${{ parameters.workingDirectory }}             --push
        displayName: "🐳 Build & Push Docker Image (Multi Arch)"

    # Inspect the image
    - bash: |
        docker image inspect ${{ parameters.imageName }}:$(Build.BuildNumber)
      displayName: Show Details of the Docker Image
      failOnStderr: false

    # Install Trivy
    - script: |
        LATEST_VERSION=($(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest           | awk '/tag_name/ {print $2}' | cut -d '"' -f 2 | cut -d 'v' -f 2))
        sudo apt-get install -y rpm
        wget https://github.com/aquasecurity/trivy/releases/download/v${LATEST_VERSION}/trivy_${LATEST_VERSION}_Linux-64bit.deb
        sudo dpkg -i trivy_${LATEST_VERSION}_Linux-64bit.deb
        trivy -v
      displayName: Download and Install Latest Trivy

    # Scan image with Trivy
    - task: CmdLine@2
      displayName: Scan the Image with Trivy CLI
      name: scanVariables
      inputs:
        script: |
          cd $(Build.SourcesDirectory)
          trivy image --exit-code 0 --severity LOW,MEDIUM             --format template --template "@${{ parameters.trivyTemplateFilePath }}"             -o junit-report-low-med.xml ${{ parameters.imageName }}:$(Build.BuildNumber)
          trivy image --exit-code 1 --severity HIGH,CRITICAL             --format template --template "@${{ parameters.trivyTemplateFilePath }}"             -o junit-report-high-crit.xml ${{ parameters.imageName }}:$(Build.BuildNumber)
          echo "##vso[task.setvariable variable=TrivyScanResults;isOutput=true;]$?"

    # Publish Trivy results
    - task: PublishTestResults@2
      displayName: Capture Low and Medium Vulnerabilities
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/junit-report-low-med.xml'
        mergeTestResults: true
        failTaskOnFailedTests: false
        testRunTitle: 'Trivy Scan - Low/Medium'
      condition: 'always()'

    - task: PublishTestResults@2
      displayName: Capture High and Critical Vulnerabilities
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/junit-report-high-crit.xml'
        mergeTestResults: true
        failTaskOnFailedTests: false
        testRunTitle: 'Trivy Scan - High/Critical'
      condition: 'always()'

    # Push Docker image to JFrog
    - task: JFrogDocker@1
      displayName: Push Container to JFrog Artifactory
      inputs:
        command: "Push"
        artifactoryConnection: "${{ parameters.serviceConnection }}"
        imageName: "${{ parameters.containerRegistry }}/${{ parameters.imageRepositoryName }}/${{ parameters.imageName }}:$(Build.BuildNumber)"
        collectBuildInfo: true
        buildName: "$(Build.DefinitionName)"
        buildNumber: "$(Build.BuildNumber)"
        threads: "3"
        skipLogin: false

    # Publish build info to JFrog
    - task: JFrogPublishBuildInfo@1
      displayName: Publish Artifactory Build Info
      condition: and(succeeded(), or(startsWith(variables['Build.SourceBranch'], 'refs/heads/releases/'), eq(variables['Build.SourceBranchName'], 'main'), eq(variables['Build.SourceBranchName'], 'master')))
      inputs:
        artifactoryConnection: "${{ parameters.serviceConnection }}"
        buildName: "$(Build.DefinitionName)"
        buildNumber: "$(Build.BuildNumber)"








build-docker-image-job.acr-jfrog-template.yaml
===========||=========
# Docker Build & Push Job Template (Combined Version)
# This template can target either:
# - Lean ACR workflow (default)
# - Enterprise JFrog workflow (with debugging, Trivy install, JFrog push & build-info)
#
# Controlled by enableJfrog parameter.

parameters:
  - name: jobName
    type: string
    default: 'Build_Push_Image_Job'
  - name: jobDisplayName
    type: string
    default: 'Build & Push Docker Image (Combined)'

  - name: artifactName
    type: string
    default: 'drop'
  - name: dockerfilePath
    type: string
    default: 'Dockerfile'
  - name: workingDirectory
    type: string
    default: '.'
  - name: imageName
    type: string
    default: ''
  - name: imageRepository
    type: string
    default: ''
  - name: imageRepositoryName
    type: string
    default: ''

  - name: containerRegistryService
    type: string
    default: ''
  - name: containerRegistry
    type: string
    default: ''

  - name: imageTags
    type: string
    default: '$(Build.BuildNumber)'

  - name: serviceConnection
    type: string
    default: ''

  - name: enableTrivyScan
    type: boolean
    default: true
  - name: trivyTemplateFilePath
    type: string
    default: 'pipelines/build/azure-devops/junit.tpl'

  - name: enableDebugging
    type: boolean
    default: false

  - name: enableJfrog
    type: boolean
    default: false

jobs:
- job: ${{ parameters.jobName }}
  displayName: ${{ parameters.jobDisplayName }}
  pool:
    vmImage: 'ubuntu-latest'

  steps:
    # Common steps for all flows
    - task: DownloadPipelineArtifact@2
      displayName: "Download Build Artifact - ${{ parameters.artifactName }}"
      inputs:
        source: 'current'
        artifact: '${{ parameters.artifactName }}'
        path: '$(Pipeline.Workspace)/${{ parameters.artifactName }}'

    # ---------- Lean ACR flow ----------
    - ${{ if ne(parameters.enableJfrog, true) }}:
      - task: Docker@2
        displayName: '🔐 Log into ACR'
        inputs:
          command: login
          containerRegistry: ${{ parameters.containerRegistryService }}

    - ${{ if ne(parameters.enableJfrog, true) }}:
      - task: Docker@2
        displayName: "🐳 Build & Push Docker Image (ACR)"
        inputs:
          command: buildAndPush
          containerRegistry: ${{ parameters.containerRegistryService }}
          repository: ${{ parameters.imageName }}
          Dockerfile: ${{ parameters.dockerfilePath }}
          buildContext: ${{ parameters.workingDirectory }}
          tags: |
            ${{ parameters.imageTags }}

    - ${{ if and(ne(parameters.enableJfrog, true), eq(parameters.enableTrivyScan, true)) }}:
      - script: |
          echo "🔍 Running Trivy scan (ACR flow)..."
          REF_TAG="$(echo "${{ parameters.imageTags }}" | head -n1)"
          trivy image             --exit-code 0 --severity LOW,MEDIUM             --format template --template "@${{ parameters.trivyTemplateFilePath }}"             -o junit-report-low-med.xml             ${{ parameters.imageRepository }}/${{ parameters.imageName }}:$REF_TAG
          trivy image             --exit-code 1 --severity HIGH,CRITICAL             --format template --template "@${{ parameters.trivyTemplateFilePath }}"             -o junit-report-high-crit.xml             ${{ parameters.imageRepository }}/${{ parameters.imageName }}:$REF_TAG
        displayName: "Trivy Scan - Image Vulnerabilities"

      - task: PublishTestResults@2
        displayName: "Publish Trivy Scan Results"
        inputs:
          testResultsFormat: 'JUnit'
          testResultsFiles: '**/junit-report-*.xml'
          mergeTestResults: true
          failTaskOnFailedTests: false
        condition: always()

    # ---------- Enterprise JFrog flow ----------
    - ${{ if eq(parameters.enableJfrog, true) }}:
      - ${{ if eq(parameters.enableDebugging, true) }}:
        - bash: |
            docker images --all
          displayName: List Docker Images
          failOnStderr: false

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - bash: |
          docker image inspect ${{ parameters.containerRegistry }}/${{ parameters.imageRepositoryName }}/${{ parameters.imageName }}:$(Build.BuildNumber)
        displayName: Show Details of the Docker Container
        failOnStderr: false

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - script: |
          LATEST_VERSION=($(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | awk '/tag_name/ {print $2}' | cut -d '"' -f 2 | cut -d 'v' -f 2))
          sudo apt-get install -y rpm
          wget https://github.com/aquasecurity/trivy/releases/download/v${LATEST_VERSION}/trivy_${LATEST_VERSION}_Linux-64bit.deb
          sudo dpkg -i trivy_${LATEST_VERSION}_Linux-64bit.deb
          trivy -v
        displayName: Download and Install the Latest Version of Trivy Image Scanner for Ubuntu

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - task: CmdLine@2
        displayName: Scan the Image with AquaSecurity's Trivy CLI
        name: scanVariables
        inputs:
          script: |
            cd $(Build.SourcesDirectory)
            trivy image --exit-code 0 --severity LOW,MEDIUM --format template --template "@${{ parameters.trivyTemplateFilePath }}" -o junit-report-low-med.xml ${{ parameters.containerRegistry }}/${{ parameters.imageRepositoryName }}/${{ parameters.imageName }}:$(Build.BuildNumber)
            trivy image --exit-code 1 --severity HIGH,CRITICAL --format template --template "@${{ parameters.trivyTemplateFilePath }}" -o junit-report-high-crit.xml ${{ parameters.containerRegistry }}/${{ parameters.imageRepositoryName }}/${{ parameters.imageName }}:$(Build.BuildNumber)
            echo "##vso[task.setvariable variable=TrivyScanResults;isOutput=true;]$?"

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - task: PublishTestResults@2
        displayName: Capture Low and Medium Vulnerabilities Test Run
        inputs:
          testResultsFormat: 'JUnit'
          testResultsFiles: '**/junit-report-low-med.xml'
          mergeTestResults: true
          failTaskOnFailedTests: false
          testRunTitle: 'Trivy Scan - Low and Medium Vulnerabilities'
        condition: 'always()'

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - task: PublishTestResults@2
        displayName: Capture High and Critical Vulnerabilities Test Run
        inputs:
          testResultsFormat: 'JUnit'
          testResultsFiles: '**/junit-report-high-crit.xml'
          mergeTestResults: true
          failTaskOnFailedTests: false
          testRunTitle: 'Trivy Scan - High and Critical Vulnerabilities'
        condition: 'always()'

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - task: JFrogDocker@1
        displayName: Push Container to Jfrog Artifactory
        inputs:
          command: "Push"
          artifactoryConnection: "${{ parameters.serviceConnection }}"
          imageName: "${{ parameters.containerRegistry }}/${{ parameters.imageRepositoryName }}/${{ parameters.imageName }}:$(Build.BuildNumber)"
          collectBuildInfo: true
          buildName: "$(Build.DefinitionName)"
          buildNumber: "$(Build.BuildNumber)"
          threads: "3"
          skipLogin: false

    - ${{ if eq(parameters.enableJfrog, true) }}:
      - task: JFrogPublishBuildInfo@1
        displayName: Publish Artifactory Build Info
        condition: and(succeeded(), or(startsWith(variables['Build.SourceBranch'], 'refs/heads/releases/'), eq(variables['Build.SourceBranchName'], 'main'), eq(variables['Build.SourceBranchName'], 'master')))
        inputs:
          artifactoryConnection: "${{ parameters.serviceConnection }}"
          buildName: "$(Build.DefinitionName)"
          buildNumber: "$(Build.BuildNumber)"








----------------------------












======================================||=======================================================
======================================|\=======================================================
azure-pipelines-direct-final.yml
========||=====
# azure-pipelines.yml
# Demonstrates direct invocation of universal DevSecOps templates with explicit values supplied.

trigger:
  branches:
    include: ['main']
pr:
  branches:
    include: ['*']

variables:
  BuildConfiguration: 'Release'

pool:
  vmImage: 'ubuntu-latest'

stages:
# -------- Path A: Deployment wrapper with environment approvals --------
- stage: Security_Scans
  displayName: 'Security Scans with Approvals'
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
  jobs:
  - template: devsecops-deployment-stage.yaml
    parameters:
      stageName: 'Security_Scans'
      environmentName: 'Security-Checks'         # <-- set up environment approvals in ADO
      resourceName: ''

      # Build/project info
      displayName: 'App'
      projectName: 'SampleProject'
      notificationStageDisplay: 'Build, Test, Scan & Analyze'

      # Build settings
      dotnetSdkVersion: '8.0.x'
      buildConfiguration: 'Release'
      projectsPattern: '**/*.csproj'

      # SonarQube integration
      sonarQubeConnection: 'SonarQubeServer'
      sonarQubeProject: 'sample-app-project'

      # Secret scanning
      enableSecretScanning: true
      secretScanningTool: gitleaks

      # Dependency scanning choice
      dependencyScanner: owasp
      enableOwaspDependencyCheck: true
      owaspFailOnCvss: '7'
      owaspEnableRetired: true
      owaspEnableExperimental: true

      # Xray scanning (off by default)
      enableJFrogScan: false
      xrayConnection: ''

      # Tests & coverage
      runUnitTests: true
      runIntegrationTests: false
      runCodeCoverage: true
      generateTestReports: true

      # Notifications
      enableTeams: false
      teamsWebhookUrl: ''
      enableSlack: false
      slackWebhookUrl: ''
      emailRecipients: ''
      notificationType: both

# -------- Path B: Normal stage using job template --------
- stage: Build_Test_Scan_Analyze
  displayName: 'Build, Test, Scan & Analyze'
  condition: ne(variables['Build.SourceBranch'], 'refs/heads/main')   # run on non-main branches
  jobs:
  - template: devsecops-job.universal.yaml
    parameters:
    # ---------- Job naming / display ----------
      jobName: 'DevSecOps'
      displayName: 'App'
      projectName: 'SampleProject'
      notificationStageDisplay: 'Build, Test, Scan & Analyze'

    # ---------- Build / restore ----------
      dotnetSdkVersion: '8.0.x'
      buildConfiguration: 'Debug'
      projectsPattern: '**/*.csproj'

    # Optional NuGet auth
      nugetServiceConnection: 'nugetServerConnection'

    # ---------- SonarQube ----------
      sonarQubeConnection: 'SonarQubeServer'
      sonarQubeProject: 'sample-app-project'
      #sonarExtraProperties: ''   # Multiline sonar.* properties if needed

    # ---------- Secrets scanning (GitLeaks) ----------
      enableSecretScanning: true
      secretScanningTool: gitleaks

    # ---------- Dependency scanning (OWASP / Xray / Advanced) ---------
      #enableOwaspDependencyCheck: true

    # Advanced dependency scanner (optional product)
      #enableAdvancedDepScan: false

    # Xray
      dependencyScanner: xray
      enableJFrogScan: true
      xrayConnection: 'MyXrayServiceConnection'

    # ---------- Tests & coverage ----------
      runUnitTests: true
      runIntegrationTests: true
      runCodeCoverage: true

    # ---------- Notifications ---------
      enableTeams: true
      teamsWebhookUrl: '$(teamsWebhook)'
      enableSlack: false
      slackWebhookUrl: ''
      emailRecipients: 'alerts@example.com'
      notificationType: both


=====================||========
azure-pipelines-direct-final-with-branch-profiles.yml
=============||================
# azure-pipelines-branch-profiles.yml
# Branch-aware pipeline that calls your DevSecOps templates with different settings
# for feature, release, and main branches (and PRs). Uses your existing templates:
#   - devsecops-deployment-stage.yaml   (deployment job with environment approvals)
#   - devsecops-job.universal.yaml      (job template)

trigger:
  branches:
    include: ['main', 'release/*', 'feature/*']
pr:
  branches:
    include: ['*']

variables:
  BuildConfiguration: 'Release'

pool:
  vmImage: 'ubuntu-latest'

stages:
# =====================
# 1) MAIN: Heavy profile (full scans, approvals)
# =====================
- ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
  - template: devsecops-deployment-stage.yaml
    parameters:
      stageName: 'Security_Scans_Main'
      environmentName: 'Security-Checks'        # <-- Configure env approvals in ADO

      # Display
      notificationStageDisplay: 'Build, Test, Scan & Analyze (Main)'

      # Build
      dotnetSdkVersion: '8.0.x'
      buildConfiguration: 'Release'
      projectsPattern: '**/*.csproj'

      # SonarQube
      sonarQubeConnection: 'SonarQubeServer'
      sonarQubeProject: 'sample-app-project'

      # Secrets
      enableSecretScanning: true

      # Dependencies (run both for main)
      dependencyScanner: both
      enableOwaspDependencyCheck: true
      owaspFailOnCvss: '7'            # fail on CVSS >= 7 (adjust to appetite)
      owaspEnableRetired: true
      owaspEnableExperimental: true

      enableJFrogScan: true
      xrayConnection: 'MyXrayServiceConnection'
      xrayWatchesSource: all
      xrayIncludeLicenses: false

      # Tests & coverage
      runUnitTests: true
      runIntegrationTests: true
      runCodeCoverage: true
      generateTestReports: true

      # Notifications
      enableTeams: true
      teamsWebhookUrl: '$(teamsWebhook)'
      enableSlack: false
      slackWebhookUrl: ''
      emailRecipients: 'secops@example.com'
      notificationType: both

# =====================
# 2) RELEASE/*: Balanced profile (primary scans, coverage, no approvals)
# =====================
- ${{ if and(ne(variables['Build.SourceBranch'], 'refs/heads/main'), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')) }}:
  - stage: Build_Test_Scan_Analyze_Release
    displayName: 'Build, Test, Scan & Analyze (Release)'
    jobs:
    - template: devsecops-job.universal.yaml
      parameters:
        jobName: 'DevSecOps_Release'
        notificationStageDisplay: 'Build, Test, Scan & Analyze (Release)'

        # Build
        dotnetSdkVersion: '8.0.x'
        buildConfiguration: 'Release'
        projectsPattern: '**/*.csproj'

        # SonarQube
        sonarQubeConnection: 'SonarQubeServer'
        sonarQubeProject: 'sample-app-project'

        # Secrets
        enableSecretScanning: true

        # Dependencies (single scanner for speed; OWASP baseline)
        dependencyScanner: owasp
        enableOwaspDependencyCheck: true
        owaspFailOnCvss: '8'         # slightly stricter threshold for release
        owaspEnableRetired: true
        owaspEnableExperimental: false

        # Tests & coverage
        runUnitTests: true
        runIntegrationTests: true      # keep integration tests on release
        runCodeCoverage: true
        generateTestReports: true

        # Notifications
        enableTeams: true
        teamsWebhookUrl: '$(teamsWebhook)'
        enableSlack: false
        emailRecipients: 'release-notify@example.com'
        notificationType: both

# =====================
# 3) FEATURE/*: Light profile (fast feedback)
# =====================
- ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/feature/') }}:
  - stage: Build_Test_Scan_Analyze_Feature
    displayName: 'Build, Test, Scan & Analyze (Feature)'
    jobs:
    - template: devsecops-job.universal.yaml
      parameters:
        jobName: 'DevSecOps_Feature'
        notificationStageDisplay: 'Build, Test, Scan & Analyze (Feature)'

        # Build
        dotnetSdkVersion: '8.0.x'
        buildConfiguration: 'Debug'      # faster builds for features
        projectsPattern: '**/*.csproj'

        # SonarQube
        sonarQubeConnection: 'SonarQubeServer'
        sonarQubeProject: 'sample-app-project'

        # Secrets
        enableSecretScanning: true

        # Dependencies (keep lean; or turn off entirely)
        dependencyScanner: owasp
        enableOwaspDependencyCheck: true
        owaspFailOnCvss: '9'            # report but don't fail aggressively
        owaspEnableRetired: false
        owaspEnableExperimental: false

        # Tests & coverage
        runUnitTests: true
        runIntegrationTests: false       # skip to keep cycles short
        runCodeCoverage: false           # disable coverage for speed
        generateTestReports: true

        # Notifications (usually off for features)
        enableTeams: false
        enableSlack: false
        emailRecipients: ''
        notificationType: both

# =====================
# 4) PR validation: moderate profile
# =====================
- ${{ if eq(variables['Build.Reason'], 'PullRequest') }}:
  - stage: PR_Validation
    displayName: 'PR Validation'
    jobs:
    - template: devsecops-job.universal.yaml
      parameters:
        jobName: 'DevSecOps_PR'
        notificationStageDisplay: 'PR Validation'

        # Build
        dotnetSdkVersion: '8.0.x'
        buildConfiguration: 'Debug'
        projectsPattern: '**/*.csproj'

        # SonarQube
        sonarQubeConnection: 'SonarQubeServer'
        sonarQubeProject: 'sample-app-project'

        # Secrets
        enableSecretScanning: true

        # Dependencies
        dependencyScanner: owasp
        enableOwaspDependencyCheck: true
        owaspFailOnCvss: '8'

        # Tests & coverage
        runUnitTests: true
        runIntegrationTests: false
        runCodeCoverage: true            # keep coverage in PRs
        generateTestReports: true

        # Notifications (often off for PRs)
        enableTeams: false
        enableSlack: false
        emailRecipients: ''
        notificationType: both


























































































