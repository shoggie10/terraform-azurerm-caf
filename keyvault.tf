
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
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "random_integer" "this" {
  min = 100
  max = 999
}

locals {
  # Data Factory name that incorporates a random integer
  data_factory_name = "adf${var.application_name}${var.tags.environment}${random_integer.this.result}"
  tfModule          = "data-factory"
  tfModule_extended = var.terraform_module != "" 
    ? join(" ", [var.terraform_module, local.tfModule]) 
    : local.tfModule
}

# Azure Data Factory
resource "azurerm_data_factory" "this" {
  name                             = local.data_factory_name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  managed_virtual_network_enabled  = var.managed_virtual_network_enabled
  public_network_enabled           = var.public_network_enabled
  customer_managed_key_id          = module.key_vault_key.key_vault_key_id
  customer_managed_key_identity_id = azurerm_user_assigned_identity.adf_identity.id # Referencing the user-assigned identity

  tags = var.tags

  dynamic "github_configuration" {
    for_each = var.github_configuration != null ? [var.github_configuration] : []
    content {
      git_url         = github_configuration.value.git_url
      account_name    = github_configuration.value.account_name
      branch_name     = github_configuration.value.branch_name
      repository_name = github_configuration.value.repository_name
      root_folder     = github_configuration.value.root_folder
    }
  }

  dynamic "global_parameter" {
    for_each = var.global_parameters
    content {
      name  = global_parameter.key
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Optional Azure Integration Runtimes for Data Factory
resource "azurerm_data_factory_integration_runtime_azure" "this" {
  for_each = var.azure_integration_runtime

  name                    = each.key
  data_factory_id         = azurerm_data_factory.this.id
  location                = var.location
  description             = each.value.description
  compute_type            = each.value.compute_type
  core_count              = each.value.core_count
  time_to_live_min        = each.value.time_to_live_min
  cleanup_enabled         = each.value.cleanup_enabled
  virtual_network_enabled = each.value.virtual_network_enabled
}







# variables.tf
----------
variable "customer_managed_key_id" {
  type        = string
  description = <<EOT
Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key (CMK).
This is typically something like:
  "https://<mykeyvault>.vault.azure.net/keys/<my-key>/<key-version>"
If null, CMK is not used.
EOT
  default = null
}

variable "customer_managed_key_identity_id" {
  type        = string
  description = <<EOT
Specifies the ID of the user assigned identity associated with the CMK. 
Required if customer_managed_key_id is set. This identity must have wrapKey/unwrapKey permissions on the Key Vault Key.
EOT
  default = null
}

# GitHub Configuration for Data Factory

variable "github_configuration" {
  description = <<EOT
An object defining the settings for connecting to GitHub.
Example:
  github_configuration = {
    git_url         = "https://github.com"
    account_name    = "my-gh-account"
    repository_name = "my-repo"
    branch_name     = "main"
    root_folder     = "/"
  }
EOT
  type = object({
    git_url         = optional(string)
    account_name    = optional(string)
    repository_name = optional(string)
    branch_name     = optional(string)
    root_folder     = optional(string)
  })
  default = null
}

# Global Parameters for Data Factory

variable "global_parameters" {
  description = <<EOT
Map of global parameters for Data Factory.
Example:
  global_parameters = {
    param1 = {
      type  = "String"
      value = "myValue"
    },
    param2 = {
      type  = "Bool"
      value = true
    }
  }
EOT
  type    = map(object({ type = string, value = any }))
  default = {}
}

# Azure Integration Runtime Configuration

variable "azure_integration_runtime" {
  type = map(object({
    description             = optional(string, "Azure Integration Runtime")
    compute_type            = optional(string, "General")
    virtual_network_enabled = optional(bool, true)
    core_count              = optional(number, 8)
    time_to_live_min        = optional(number, 0)
    cleanup_enabled         = optional(bool, true)
  }))
  description = <<EOF
Map of Azure Integration Runtime configurations.
Example:
  azure_integration_runtime = {
    az-ir-gen-01 = {
      compute_type            = "General"
      virtual_network_enabled = true
      core_count              = 8
      time_to_live_min        = 0
      cleanup_enabled         = true
    }
  }
EOF
  default = {}
}

variable "terraform_module" {
  description = "Used to inform of a parent module if nested. Otherwise, leave blank."
  type        = string
  default     = ""
}

# Required Input Standard Variables

variable "application_name" {
  type        = string
  description = "The name of the resource."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}

# Tags for Resources

variable "tags" {
  type        = map(string)
  description = <<-EOT
  Required BOKF tags are listed below with sample values. These values are validated by the underlying Tags module.

    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "confidential"
    managed_by          = "it_cloud"
    cost_center         = "1234"
    source_code         = "https://gitlab.com/company/test"
    deployed_by         = "test-workspace"
    application_role    = "app"

  EOT
}

# Data Factory Network Settings

variable "public_network_enabled" {
  type        = bool
  description = "(Optional) Is the Data Factory visible to the public network? Defaults to true"
  default     = true
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Is Managed Virtual Network enabled?"
  default     = true
}





# locals.tf
------------
variable "application_name" {
  type        = string
  description = "The name of the resource."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}

# Tags for Resources
variable "tags" {
  type        = map(string)
  description = <<-EOT
  Required BOKF tags are listed below with sample values. These values are validated by the underlying Tags module.

    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "confidential"
    managed_by          = "it_cloud"
    cost_center         = "1234"
    source_code         = "https://gitlab.com/company/test"
    deployed_by         = "test-workspace"
    application_role    = "app"
  EOT
}

# Network-related variables for Key Vault Network ACLs
variable "private_endpoints" {
  type    = list(any)
  default = []
  description = "A list of private endpoints that can be used for access control to the Key Vault."
}

variable "ip_range_filter" {
  type    = list(string)
  default = []
  description = "A list of IP address ranges allowed to access the Key Vault."
}

variable "virtual_network_subnet_ids" {
  type    = list(string)
  default = []
  description = "A list of subnet IDs from virtual networks allowed to access the Key Vault."
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Is Managed Virtual Network enabled?"
  default     = true
}

variable "public_network_enabled" {
  type        = bool
  description = "(Optional) Is the Data Factory visible to the public network? Defaults to true"
  default     = true
}

# Required Input Standard Variables
variable "customer_managed_key_id" {
  type        = string
  description = "Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key (CMK) for double encryption. Required with user assigned identity."
  default     = null
}

variable "customer_managed_key_identity_id" {
  type        = string
  description = "Specifies the ID of the user assigned identity associated with the Customer Managed Key. Must be supplied if customer_managed_key_id is set."
  default     = null
}

variable "github_configuration" {
  description = "An input object to define the settings for connecting to GitHub. NOTE! You must log in to the Data Factory management UI to complete the authentication to the GitHub repository."
  type = object({
    git_url         = optional(string) # - OPTIONAL: Specifies the GitHub Enterprise host name. Defaults to "https://github.com"
    account_name    = optional(string) # - REQUIRED: Specifies the GitHub account name. Defaults to ''
    repository_name = optional(string) # - REQUIRED: Specifies the name of the git repository. 
    branch_name     = optional(string) # - OPTIONAL: Specifies the branch of the repository to get code from. Defaults to 'main'
    root_folder     = optional(string) # - OPTIONAL: Specifies the root folder within the repository. Defaults to '/' for top level.
  })
  default = null
}

variable "global_parameters" {
  type        = any
  description = "An input object to define a global parameter. Accepts multiple entries."
  default     = {}
}

variable "azure_integration_runtime" {
  type = map(object({
    description             = optional(string, "Azure Integrated Runtime")
    compute_type            = optional(string, "General")
    virtual_network_enabled = optional(string, true)
    core_count              = optional(number, 8)
    time_to_live_min        = optional(number, 0)
    cleanup_enabled         = optional(bool, true)
  }))
  description = <<EOF
  Map Object to define any Azure Integration Runtime nodes that required.
  key of each object is the name of a new node.
  configuration parameters within the object allow customization.
  EXAMPLE:
  azure_integration_runtime = {
    az-ir-co-01 {
      "compute_type" .  = "ComputeOptimized"
      "cleanup_enabled" = true
      core_count        = 16
    },
    az-ir-gen-01 {},
    az-ir-gen-02 {},
  }
EOF
  default     = {}
}

variable "terraform_module" {
  description = "Used to inform of a parent module"
  type        = string
  default     = ""
}






# outputs.tf
----------
output "id" {
  description = "The ID of the new Datafactory resource."
  value       = azurerm_data_factory.this.id
}

output "name" {
  description = "The name of the newly created Azure Data Factory"
  value       = azurerm_data_factory.this.name
}


output "global_paramaters" {
  description = "A map showing any created Global Parameters."
  value       = { for gp in azurerm_data_factory.this.global_parameter : gp.name => gp }
}






# examples.tf
-----------
provider "azurerm" {
  #4.0+ version of AzureRM Provider requires a subscription ID  
  subscription_id = "b987518f-1b04-4491-915c-e21dabc7f2d3"    #"0b5a3199-58bb-40ef-bcce-76a53aa594c2"

  #resource_provider_registrations = "none"

  features {

  }
}

locals {
  tags = {
    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "confidential"
    managed_by          = "it_cloud"
    requested_by        = "me@email.com"
    cost_center         = "1234"
    source_code         = "https://gitlab.com/company/test"
    deployed_by         = "test-workspace"
    application_role    = ""
  }
}


data "azurerm_resource_group" "this" {
  name = "wayne-tech-hub"
}

# data "azurerm_cosmosdb_account" "this" {
#   name                = "cdbwaynetechhubdev259678"
#   resource_group_name = data.azurerm_resource_group.this.name
# }

data "azuread_user" "this" {
  user_principal_name = "salonge@bokf.com"   # "SXA7BU_PA@bokf.onmicrosoft.com"
}

module "this" {
  source                          = "../"


  #data_factory_name               = "adf-test-001"
  application_name = "datafactory1"
  resource_group_name             = "wayne-tech-hub"
  location                        = data.azurerm_resource_group.this.location
  tags = local.tags


  global_parameters = {
    "testbool" = {
      type  = "Bool"
      value = true
    }
  }

}









===========||=========
customer-managed-key.tf

# Create the Key Vault resource using the Key Vault module
module "key_vault" {
  source  = "app.terraform.io/xxxx/key-vault/azure"
  version = "<0.2.0>"

  application_name                = "adf-cmk"  
  enabled_for_template_deployment = true
  resource_group_name             = var.resource_group_name

  # Network ACLs configuration
  network_acls = {
    # Bypass must be set to AzureServices for Data Factory CMK usage when not using Private Endpoints
    bypass = length(var.private_endpoints) != 0 ? "None" : "AzureServices"
    # Set to allow only if no private endpoints, IP Rules, or VNet rules exist.
    default_action             = length(var.private_endpoints) == 0 && length(var.ip_range_filter) == 0 && length(local.cmk.virtual_network_subnet_ids) == 0 ? "Allow" : "Deny"
    ip_rules                   = var.ip_range_filter
    virtual_network_subnet_ids = local.cmk.virtual_network_subnet_ids
  }

  tags = var.tags
}

# Key Vault RBAC configuration to assign necessary permissions
module "key_vault_rbac" {
  source  = "app.terraform.io/xxxx/common/azure"
  resource_name = module.key_vault.display_name
  resource_id   = module.key_vault.id

  role_based_permissions = {
    terraform = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }

    adf_managed_identity_read = {
      role_definition_id_or_name = "Key Vault Reader"
      principal_id               = azurerm_user_assigned_identity.adf_identity.principal_id # Fixed to use user-assigned identity
    }

    adf_managed_identity = {
      role_definition_id_or_name = "Key Vault Crypto User"
      principal_id               = azurerm_user_assigned_identity.adf_identity.principal_id # Fixed to use user-assigned identity
    }
  }
}

# Create a Key Vault Key to use for Customer Managed Key (CMK) encryption in Azure Data Factory
module "key_vault_key" {
  source  = "app.terraform.io/xxxx/key-vault-key/azure"
  version = "<0.2.0>"

  key_vault_resource_id = module.key_vault.id
  name                  = "${local.data_factory_name}-encryption"
  type                  = "RSA"
  size                  = "3072"
  opts                  = ["encrypt", "decrypt", "sign", "unwrapKey", "wrapKey"]
  tags                  = var.tags
}

# Create a User Assigned Managed Identity required for Data Factory to use CMK
resource "azurerm_user_assigned_identity" "adf_identity" {
  name                = "${local.data_factory_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create Azure Data Factory using the customer-managed key for encryption
resource "azurerm_data_factory" "this" {
  name                             = local.data_factory_name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  managed_virtual_network_enabled  = var.managed_virtual_network_enabled
  public_network_enabled           = var.public_network_enabled
  customer_managed_key_id          = module.key_vault_key.key_vault_key_id
  customer_managed_key_identity_id = azurerm_user_assigned_identity.adf_identity.id

  tags = var.tags

  dynamic "github_configuration" {
    for_each = var.github_configuration != null ? [var.github_configuration] : []
    content {
      git_url         = github_configuration.value.git_url
      account_name    = github_configuration.value.account_name
      branch_name     = github_configuration.value.branch_name
      repository_name = github_configuration.value.repository_name
      root_folder     = github_configuration.value.root_folder
    }
  }

  dynamic "global_parameter" {
    for_each = var.global_parameters
    content {
      name  = global_parameter.key
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Optional Azure Integration Runtimes for Data Factory
resource "azurerm_data_factory_integration_runtime_azure" "this" {
  for_each = var.azure_integration_runtime

  name                    = each.key
  data_factory_id         = azurerm_data_factory.this.id
  location                = var.location
  description             = each.value.description
  compute_type            = each.value.compute_type
  core_count              = each.value.core_count
  time_to_live_min        = each.value.time_to_live_min
  cleanup_enabled         = each.value.cleanup_enabled
  virtual_network_enabled = each.value.virtual_network_enabled
}

----------------------------












======================================||=======================================================
======================================|\=======================================================

module "keyvault_access_policies" {
  source   = "./modules/security/keyvault_access_policies"
  for_each = var.keyvault_access_policies

  keyvault_key    = each.key
  keyvaults       = local.combined_objects_keyvaults
  access_policies = each.value
  azuread_groups  = local.combined_objects_azuread_groups
  client_config   = local.client_config
  resources = {
    azuread_service_principals        = local.combined_objects_azuread_service_principals
    diagnostic_storage_accounts       = local.combined_objects_diagnostic_storage_accounts
    managed_identities                = local.combined_objects_managed_identities
    mssql_managed_instances           = local.combined_objects_mssql_managed_instances
    mssql_managed_instances_secondary = local.combined_objects_mssql_managed_instances_secondary
    storage_accounts                  = local.combined_objects_storage_accounts
  }
}


# Need to separate keyvault policies from azure AD apps to get the keyvault with the default policies.
# Reason - Azure AD apps passwords are stored into keyvault secrets and combining would create a circular reference
module "keyvault_access_policies_azuread_apps" {
  source   = "./modules/security/keyvault_access_policies"
  for_each = var.keyvault_access_policies_azuread_apps

  keyvault_key    = each.key
  keyvaults       = local.combined_objects_keyvaults
  access_policies = each.value
  client_config   = local.client_config
  azuread_apps    = local.combined_objects_azuread_apps
}


output "keyvaults" {
  value = module.keyvaults

}
