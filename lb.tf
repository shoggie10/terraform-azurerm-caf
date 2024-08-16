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
==========||========================
A significant overhaul of your Azure DevOps setup using Terraform, which is a crucial step in ensuring that your infrastructure as code practices are up to date, maintainable, and scalable. Here’s how you can structure comprehensive documentation for your Azure DevOps Project module refactor based on the components you mentioned:

### 1. Introduction
- **Purpose**: Explain the purpose of the refactor, such as improving readability, maintainability, and scalability of the Terraform code.
- **Scope**: Define the components of Azure DevOps being managed by Terraform in this module.

### 2. Terraform Module Overview
- **Structure Changes**: Detail the structural changes made, such as the distribution of resources into separate files (Branch Policies, Git Repositories, etc.).
- **Resource Management**: List and describe each type of resource managed by this module, emphasizing new additions.

### 3. Detailed Configuration Sections
For each type of resource, provide the following details:

#### Branch Policies
- **Description**: What branch policies are implemented (e.g., branch protection rules, merge strategies).
- **Configuration Examples**: Provide Terraform code snippets.

#### Git Repositories
- **Description**: Outline how repositories are configured, including settings for visibility and permissions.
- **Configuration Examples**: Include relevant Terraform snippets.

#### Groups and Teams
- **Description**: Describe how teams and groups are structured within Azure DevOps and their permissions.
- **Configuration Examples**: Show how these are declared in Terraform.

#### Wiki
- **Description**: Explain the provisioning and configuration of project wikis.
- **Configuration Examples**: Terraform code for setting up wikis.

### 4. Advanced Configurations
#### Environments
- **Description and Usage**: How environments are used for deployment stages.
- **Configuration Examples**: Detailed examples.

#### Fine-grained Permissions and RBAC Permissions
- **Description**: Describe the implementation of role-based access controls and fine-grained permissions.
- **Configuration Examples**: Specific Terraform configurations for these permissions.

#### Pipelines, Pipeline Folders, and Authorizations
- **Description**: Configuration of pipelines, organization into folders, and authorization mechanisms.
- **Configuration Examples**: Provide comprehensive examples.

#### Service Connections
- **Types and Configurations**:
  - **AzureRM**: Configurations specific to Azure Resource Manager.
  - **Nuget**: Setup for Nuget package management.
  - **AWS**: Integration configurations for AWS resources.
- **Configuration Examples**: Terraform snippets for each service connection.

### 5. Testing and Validation
- **Testing Framework**: Outline the Terraform tests added to validate configurations.
- **How to Run Tests**: Instructions on executing the tests.

### 6. Maintenance and Troubleshooting
- **Updating Modules**: Guidelines on how to update the module as new versions of Terraform or Azure DevOps features are released.
- **Common Issues and Solutions**: A section dedicated to troubleshooting common issues that might arise with the configurations.

### 7. Conclusion
- **Summary**: Recap the objectives achieved with the refactor.
- **Future Plans**: Any anticipated further improvements or expansions.

### 8. Appendices
- **Change Log**: Document the history of changes to the module.
- **References**: Links to Azure DevOps and Terraform documentation that support the configurations.

This structure should provide a clear and comprehensive guide to your Azure DevOps Terraform module, making it accessible for both current users and future maintainers.

===========================|\=============================
PART-1
# Azure DevOps Terraform Module Documentation

## Overview
This document provides detailed information on the Terraform module designed to configure and manage various Azure DevOps resources. This refactor aims to enhance readability, ease maintenance, and facilitate updates by separating resources into individual files.

## Module Structure
The following resources have been organized into separate Terraform files:
- **Branch Policies**
- **Git Repositories**
- **Groups**
- **Teams**
- **Wiki**

Each section below provides configuration details and usage instructions for these resources.

### Branch Policies
#### Description
Branch policies are critical for maintaining the integrity of the codebase. They ensure that certain conditions are met before changes can be merged into a branch.

#### Configuration
- **File**: `branch_policies.tf`
- **Key Configurations**:
  - Minimum number of reviewers
  - Build validation
  - Comment resolution
Permissions
Deny:

#### Example
```hcl
resource "azuredevops_branch_policy_min_reviewers" "example" {
  project_id = azuredevops_project.project.id
  enabled    = true
  blocking   = true
  settings {
    minimum_approver_count = 2
    creator_vote_counts   = false
    scope {
      repository_id  = azuredevops_git_repository.repository.id
      repository_ref = "refs/heads/main"
    }
  }
}
```

### Git Repositories
#### Description
Manage Git repositories, specifying their visibility, permissions, and integration settings.

#### Configuration
- **File**: `git_repositories.tf`

#### Example
```hcl
resource "azuredevops_git_repository" "example" {
  project_id = azuredevops_project.project.id
  name       = "example"
  initialization {
    init_type = "Clean"
  }
}
```

### Groups
#### Description
Defines user groups within Azure DevOps to manage permissions and access control efficiently.

#### Configuration
- **File**: `groups.tf`

#### Example
```hcl
resource "azuredevops_group" "example" {
  scope        = azuredevops_project.project.id
  display_name = "Example Group"
  description  = "A group for example purposes"
}
```

### Teams
#### Description
Teams are used to group individuals working together, often with shared responsibilities and resources.

#### Configuration
- **File**: `teams.tf`

#### Example
```hcl
resource "azuredevops_team" "example" {
  project_id   = azuredevops_project.project.id
  name         = "Example Team"
  description  = "A team for example purposes"
}
```

### Wiki
#### Description
Provision and manage project wikis to support team collaboration and information sharing.

#### Configuration
- **File**: `wiki.tf`

#### Example
```hcl
resource "azuredevops_wiki" "example" {
  project_id = azuredevops_project.project.id
  name       = "Example Wiki"
  repository_id = azuredevops_git_repository.repository.id
}
```

## Maintenance and Updates
Ensure that you update this module in accordance with new Terraform releases and changes in Azure DevOps features.

## Troubleshooting
Include common issues and troubleshooting steps specific to each resource.

---

This template structures the documentation in a way that aligns with best practices for Terraform module documentation, focusing on clarity and ease of use for both new users and existing team members. Adjustments can be made to better fit specific requirements or preferences within your organization.
=========================|\===============================================

PART 2:
Here's a standard documentation template tailored for the newly supported resources in your Azure DevOps Terraform module:

---

# Azure DevOps Terraform Module Documentation

## Overview
This document provides configuration details and usage guidelines for the newly supported resources within our Azure DevOps Terraform module. This update introduces support for a broader range of infrastructure components, focusing on security, pipeline management, and service connectivity.

## Supported Resources
This module now supports the provisioning and management of the following resources:

### Environments
#### Description
Environments in Azure DevOps are used for managing deployment targets and security for deployments across different stages.

#### Configuration
- **File**: `environments.tf`

#### Example
```hcl
resource "azuredevops_environment" "production" {
  project_id = azuredevops_project.project.id
  name       = "Production"
}
```

### Fine-grained Permissions
#### Description
Manage detailed permissions settings to control access at a granular level within projects.

#### Configuration
- **File**: `permissions.tf`

#### Example
```hcl
resource "azuredevops_permissions" "developer" {
  project_id = azuredevops_project.project.id
  principal  = azuredevops_group.developer.id
  permissions = {
    EditBuildQuality = "Allow"
    DeleteBuilds     = "Deny"
  }
}
```

### RBAC Permissions
#### Description
Role-Based Access Control (RBAC) permissions are critical for enforcing security policies through roles.

#### Configuration
- **File**: `rbac_permissions.tf`

#### Example
```hcl
resource "azuredevops_rbac_permissions" "lead_dev" {
  role_definition_id = "role_definition_id_example"
  principal_id       = azuredevops_user.lead_dev.id
}
```

### Pipelines
#### Description
Configure and manage build and release pipelines.

#### Configuration
- **File**: `pipelines.tf`

#### Example
```hcl
resource "azuredevops_pipeline" "ci_pipeline" {
  name         = "CI Pipeline"
  project_id   = azuredevops_project.project.id
  yaml_path    = "azure-pipelines.yml"
}
```

### Pipeline Folders
#### Description
Organize pipelines into folders for better management and visibility.

#### Configuration
- **File**: `pipeline_folders.tf`

#### Example
```hcl
resource "azuredevops_pipeline_folder" "frontend" {
  name        = "Frontend"
  description = "Contains all frontend related pipelines"
}
```

### Pipeline Authorizations
#### Description
Manage authorization settings to control access to pipeline resources.

#### Configuration
- **File**: `pipeline_authorizations.tf`

#### Example
```hcl
resource "azuredevops_pipeline_authorization" "external_service" {
  pipeline_id = azuredevops_pipeline.ci_pipeline.id
  authorized  = true
}
```

### Service Connections
Manage connections to external services that support deployment and operations activities.

#### AzureRM
- **File**: `service_connections.tf`
- **Example**
```hcl
resource "azuredevops_service_connection_azurerm" "azure_connection" {
  name        = "Azure Connection"
  project_id  = azuredevops_project.project.id
  credentials {
    service_principal_id     = var.service_principal_id
    service_principal_key    = var.service_principal_key
    tenant_id                = var.tenant_id
  }
}
```

#### Nuget
- **File**: `service_connections.tf`
- **Example**
```hcl
resource "azuredevops_service_connection_nuget" "nuget_feed" {
  name        = "Nuget Feed"
  project_id  = azuredevops_project.project.id
  nuget_url   = "https://nuget.org/api/v2/"
}
```

#### AWS
- **File**: `service_connections.tf`
- **Example**
```hcl
resource "azuredevops_service_connection_aws" "aws_connection" {
  name        = "AWS Connection"
  project_id  = azuredevops_project.project.id
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}
```

## Maintenance and Updates
Regularly update this module to incorporate changes in Azure DevOps features and Terraform capabilities. Follow Terraform best practices for versioning and state management.

## Troubleshooting
Include a section on common issues and resolutions to assist users in diagnosing and fixing problems.

---

This documentation covers each new resource supported by your Terraform module, providing a clear guide for other team members on how to use and extend the module effectively. Adjust and expand sections as needed based on your specific configurations and organizational requirements.
=============================||=================================================


========
artifact feeds also use this RBAC role permission but with different, and more, roles.

the scope value here determines what type of resource we are applying these permissions for
 

module "lb_backend_address_pool" {
  source   = "./modules/networking/lb_backend_address_pool"
  for_each = local.networking.lb_backend_address_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value


  remote_objects = {
    lb = local.combined_objects_lb
  }
}
output "lb_backend_address_pool" {
  value = module.lb_backend_address_pool
}

module "lb_backend_address_pool_address" {
  source   = "./modules/networking/lb_backend_address_pool_address"
  for_each = local.networking.lb_backend_address_pool_address

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    virtual_network         = local.combined_objects_networking
    lb_backend_address_pool = local.combined_objects_lb_backend_address_pool
  }
}
output "lb_backend_address_pool_address" {
  value = module.lb_backend_address_pool_address
}

module "lb_nat_pool" {
  source   = "./modules/networking/lb_nat_pool"
  for_each = local.networking.lb_nat_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_nat_pool" {
  value = module.lb_nat_pool
}
module "lb_nat_rule" {
  source   = "./modules/networking/lb_nat_rule"
  for_each = local.networking.lb_nat_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_nat_rule" {
  value = module.lb_nat_rule
}

module "lb_outbound_rule" {
  source   = "./modules/networking/lb_outbound_rule"
  for_each = local.networking.lb_outbound_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group          = local.combined_objects_resource_groups
    lb                      = local.combined_objects_lb
    lb_backend_address_pool = local.combined_objects_lb_backend_address_pool
  }
}
output "lb_outbound_rule" {
  value = module.lb_outbound_rule
}

module "lb_probe" {
  source   = "./modules/networking/lb_probe"
  for_each = local.networking.lb_probe

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_probe" {
  value = module.lb_probe
}
module "lb_rule" {
  source   = "./modules/networking/lb_rule"
  for_each = local.networking.lb_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  backend_address_pool_ids = can(each.value.backend_address_pool_ids) || can(each.value.backend_address_pool) == false ? try(each.value.backend_address_pool_ids, null) : [
    for k, v in each.value.backend_address_pool : local.combined_objects_lb_backend_address_pool[try(v.lz_key, local.client_config.landingzone_key)][v.key].id
  ]
  probe_id = can(each.value.probe_id) || can(each.value.probe.key) == false ? try(each.value.probe_id, null) : local.combined_objects_lb_probe[try(each.value.probe.lz_key, local.client_config.landingzone_key)][each.value.probe.key].id

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_rule" {
  value = module.lb_rule
}
