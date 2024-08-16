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
Here's a detailed documentation template for the new functionality you've added to your Azure DevOps Terraform module:

---

# Azure DevOps Terraform Module: New Functionality Documentation

## Overview
This document describes the latest enhancements to our Azure DevOps Terraform module, focusing on automation and security improvements. These updates facilitate automatic provisioning, permission settings, and resource management across Azure DevOps projects.

## New Functionalities
Below are the major functionalities added to the module:

### 1. Automatic Provisioning of Environments
#### Description
This functionality automatically provisions environments based on the pipelines and declared `deployment_environments`. This ensures that all necessary environments are setup without manual intervention, directly corresponding to the deployment needs of each pipeline.

#### Configuration
- **Trigger**: Automatically triggered by the creation or update of pipelines.
- **File**: `auto_environments.tf`

#### Example
```hcl
module "auto_provision_environments" {
  source   = "./modules/auto_environments"
  for_each = var.deployment_environments
  environment_name = each.key
  pipeline_id      = azuredevops_pipeline.ci_pipeline.id
}
```

### 2. Automatic Permission for Service Connections
#### Description
Upon creation of each Service Connection, limited project admin permissions are automatically assigned, streamlining access control and minimizing manual setup.

#### Configuration
- **Trigger**: Automatically triggered by the creation of Service Connections.
- **File**: `auto_service_connections.tf`

#### Example
```hcl
resource "azuredevops_service_connection" "example" {
  name        = "Example Service Connection"
  project_id  = azuredevops_project.project.id
  permissions {
    principal_id   = azuredevops_group.limited_admin.id
    permission_set = "Admin"
  }
}
```

### 3. Automatic Pipeline Authorization
#### Description
Automatically grants necessary pipeline authorizations for environments, repositories, and service connections upon their creation.

#### Configuration
- **Trigger**: Automatically triggered by the creation of pipelines, environments, and service connections.
- **File**: `auto_pipeline_authorizations.tf`

#### Example
```hcl
resource "azuredevops_pipeline_authorization" "auto_auth" {
  pipeline_id    = each.value.pipeline_id
  environment_id = each.value.environment_id
  authorized     = true
}
```

### 4. Creation of Permissions for Limited Project Admin
#### Description
Defines and implements permissions across the project for Limited Project Admins, covering a wide range of resources to ensure comprehensive access control tailored to role requirements.

#### Configuration
- **Resources Covered**:
  - Area Path
  - Pipeline Folders
  - Git Repos
  - Iteration Paths
  - Project-Level
  - ServiceHooks
  - Environments
  - Variable Group/Secure Files
  - Artifacts
  - Test Plans
  - Feed

- **File**: `limited_admin_permissions.tf`

#### Example
```hcl
resource "azuredevops_permissions" "limited_admin" {
  for_each = toset([
    "Area Path", "Pipeline Folders", "Git Repos", "Iteration Paths",
    "Project-Level", "ServiceHooks", "Environments", "Variable Group/Secure Files",
    "Artifacts", "Test Plans", "Feed"
  ])
  principal_id  = azuredevops_group.limited_admin.id
  permissions   = {
    View = "Allow"
    Edit = "Allow"
    Admin = "Conditional"
  }
}
```

## Maintenance and Updates
Regular updates are necessary to align with Azure DevOps changes and Terraform version upgrades. Ensure testing in non-production environments before deploying changes live.

## Troubleshooting
Provide troubleshooting tips and common error resolutions to help users quickly resolve issues encountered during the setup and operation of these new functionalities.

---

This documentation template is designed to give a clear and thorough overview of the new functionalities added to your Terraform module, ensuring that team members can understand and utilize these features effectively. Adjust content to fit the specific technical details and operational context of your organization.


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
