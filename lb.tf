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
