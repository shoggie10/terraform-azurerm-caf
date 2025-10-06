
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

Azure DevOps Pipelines Technical Audit Report
1. Executive Summary
This technical audit examines Azure DevOps pipelines across multiple frameworks, including .NET Core, Java, NodeJS, Python, and Docker. The review identifies gaps in configuration management, security, process automation, tooling integration, and code standardization. The findings reveal several areas where hardcoding, non-parameterization, and limited reusability reduce the pipelines' scalability, maintainability, and flexibility.
2. Pipeline Architecture Overview
The pipelines follow a consistent pattern — Build → Test → Scan → Deploy — but with varying toolsets and inconsistent practices across frameworks. Most YAML pipelines are framework-specific with repeated logic, static variables, and missing modular templates. While functional, this design limits flexibility and complicates maintenance, onboarding, and security compliance.
3. Identified Gaps and Risks
3.1 Hardcoding and Lack of Parameterization
- Hardcoded values for environment names, registry URLs, service connections, and paths (e.g., 'XXXX_xray_connection_v2', 'XXXX-Environment-Test').
- Missing reusable variables for build configuration, versioning, or deployment paths.
- Docker image tags and artifact paths are static, leading to potential conflicts between environments.
- Build logic tied to specific branches without flexible branching conditions or parameter-driven execution.
3.2 Lack of Template and Module Reuse
- Each YAML duplicates Build, Test, and Deploy logic across frameworks.
- No centralized template repository for standard tasks (e.g., authentication, artifact handling, deployment).
- No abstraction for framework-agnostic tasks like SonarQube scan or artifact publication.
- Increased maintenance overhead as updates must be applied to every individual pipeline.
3.3 Security and Secret Management Gaps
- Tokens and credentials are stored as plain environment variables (e.g., TWINE_TOKEN, PIP_TOKEN).
- Service connections and secret keys are visible within YAML definitions.
- Lack of integration with Azure Key Vault for centralized secret storage.
- No approval checks or manual validations for production deployment stages.
3.4 Tooling Inconsistencies
- Different frameworks use different scanners (SonarQube, JFrog, custom scripts) with inconsistent enforcement.
- Lack of common logging or telemetry strategy.
- Some pipelines lack unit test coverage or code quality gates.
- No vulnerability scanning consistency across pipelines (only Java and Docker use JFrog Xray).
3.5 Flexibility and Scalability Issues
- Static Dev/Test/Prod stages instead of parameter-driven environment selection.
- Inline scripting (Bash, PowerShell) reduces maintainability.
- Pipelines cannot easily onboard new repositories or applications without copying YAML files.
- No global naming or artifact versioning standards enforced.
4. Framework-Specific Findings
.NET Core Pipelines
- Over-reliance on inline tasks with minimal use of reusable templates.
- SonarQube and JFrog integrations are inconsistent.
- Multiple redundant testing stages (unit, component, integration) without shared logic.
- Missing rollback or failure recovery logic in deployments.
Java Pipelines
- PowerShell scripts are used for modifying settings.xml instead of parameterized secure replacements.
- SonarQube configuration and credentials are partially hardcoded.
- Missing retry and error handling for Maven build steps.
- Lack of standard build artifact naming and version control.
NodeJS Pipelines
- Inline scripts for npm builds and tests instead of shared reusable tasks.
- Limited dependency scanning; no integration with OWASP or npm audit.
- Hardcoded resource groups and environment variables.
- No version tagging or artifact promotion logic between environments.
Python Pipelines
- Docker-in-Docker testing increases build complexity and runtime costs.
- SonarQube and coverage tasks are not centralized.
- TWINE and PIP tokens are used directly in scripts.
- No structured test matrix for multi-version compatibility testing.
Docker Pipelines
- Image names, ACR URLs, and tags are hardcoded.
- Missing logic for versioned tagging or environment-based image promotion.
- No centralized artifact registry governance.
- Manual environment configuration and lack of modular deployment templates.
5. Recommendations and Modernization Plan
1. **Centralize Reusable Templates** – Create a unified templates repository with modular Build, Test, and Deploy templates.
2. **Parameterize Everything** – Use pipeline parameters for environment names, connection strings, and registry URLs.
3. **Integrate Azure Key Vault** – Replace inline secrets with Key Vault references.
4. **Adopt Unified Scanning Framework** – Standardize code quality, dependency, and vulnerability scanning.
5. **Enable Dynamic Deployments** – Implement conditional stage triggers based on runtime variables or branch logic.
6. **Standardize Artifact Management** – Enforce naming and tagging conventions across frameworks.
7. **Improve Observability** – Add build telemetry, alerting, and post-deployment validation.
8. **RBAC and Governance Controls** – Restrict pipeline approvals and access using Azure DevOps Environment Checks.
====||=====
Recommendations and Modernization Plan
•	Move to template-based pipelines (reduce repetition).
•	Integrate variable groups and key vaults for secrets.
•	Adopt multi-stage pipelines using parameters for environments.
•	Introduce SonarQube, Checkmarx, Dependency Scanning, and container security consistency across all frameworks.
•	Enforce approvals, environment protections, and use conditioned triggers for better governance.
•	Migrate repeated steps to shared repository templates.

6. Conclusion
The current Azure DevOps pipelines deliver foundational CI/CD functionality but suffer from excessive hardcoding, limited modularity, and inconsistent tooling practices. By adopting shared templates, parameterized inputs, and integrated security tooling, the organization can significantly enhance its DevOps maturity, reduce maintenance burden, and improve overall security posture.

========================|\========================
Azure DevOps Pipelines Modernization – Remediation Plan
Centralized, parameterized templates enabling consistency, security, and scalability across pipelines.
1. Target Architecture
- Central template repo with build/scan/deploy primitives.
- Consumer repos assemble templates via parameters.
- Variable groups + Key Vault for secrets.
2. Migration Phases
Phase 1: Extract & template common steps.
Phase 2: Parameterize and replace hardcoding.
Phase 3: Pilot adoption.
Phase 4: Full rollout + governance.
3. Governance & Versioning
Semantic versioning, PR checks, code owners, changelog, deprecation policy.
4. Example Consumer Pipeline
resources:
  repositories:
    - repository: templates
      type: git
      name: AzureDevOps.Enterprise.Templates
      ref: refs/heads/main

stages:
- template: templates/build/dotnet-build.yaml@templates
  parameters:
    projectName: 'Contoso.Api'
    sonarProjectKey: 'Contoso.Api'

- template: templates/scan/jfrog-scan.yaml@templates
  parameters:
    jfrogService: 'contoso_jfrog'

- template: templates/deploy/acr-deploy.yaml@templates
  parameters:
    containerRegistryService: 'contoso_acr'
    repository: 'contoso/api'
    tags: |
      latest
      $(Build.BuildId)






























































































