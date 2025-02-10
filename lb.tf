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


=================||
https://us05web.zoom.us/j/86526167418?pwd=eugwcO1uniIUdwitbn3ActMoO5CCjG.1




=========




======||===

-----\\---





-----------------------------------------------------

## examples
provider "azurerm" {
  #4.0+ version of AzureRM Provider requires a subscription ID  
  subscription_id = "b987518f-1b04-4491-915c-e21dabc7f2d3" #"0b5a3199-58bb-40ef-bcce-76a53aa594c2"

  #resource_provider_registrations = "none"

  features {

  }
}


locals {
  tags = {
    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "public" #"confidential"
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
  user_principal_name = "salonge@bokf.com" # "SXA7BU_PA@bokf.onmicrosoft.com"
}



module "this" {
  source = "../"

  application_name    = "waynetechhub"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  tags = local.tags


  consistency_policy = {
    consistency_level       = "ConsistentPrefix"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }


  geo_locations = [
    {
      location          = "eastus2"
      failover_priority = 0
      zone_redundant    = false
    }
    #,
    # {
    #   location          = "centralus"
    #   failover_priority = 1
    #    zone_redundant = false

    # }
  ]

  #is_msdn_cosmosdb = true
}






================================||
# customer-managed-key.tf
module "key_vault" {
  source  = "app.terraform.io/bokf/key-vault/azure"
  version = "< 0.2.0"

  application_name                = "cosmosdbcmk"  
  enabled_for_template_deployment = true
  resource_group_name             = var.resource_group_name

  network_acls = {
    # Bypass must be set to AzureServices for CosmosDB CMK usage when not using Private Endpoints
    bypass = length(var.private_endpoints) != 0 ? "None" : "AzureServices"
    # Set to allow only if no PE, IP Rules, or VNet rules exist.
    default_action             = length(var.private_endpoints) == 0 && length(var.ip_range_filter) == 0 && length(local.cmk.virtual_network_subnet_ids) == 0 ? "Allow" : "Deny"
    ip_rules                   = var.ip_range_filter
    virtual_network_subnet_ids = local.cmk.virtual_network_subnet_ids
  }

  tags = var.tags
}


module "key_vault_rbac" {
  source  = "app.terraform.io/bokf/common/azure"
  #version = "< 0.2.0"
  resource_name = module.key_vault.display_name
  resource_id = module.key_vault.id

  #depends_on = [azurerm_cosmosdb_account.this]


  role_based_permissions = {
    terraform = {
      role_definition_id_or_name = "Key Vault Administrator" # "Key Vault Contributor" 
      principal_id = data.azurerm_client_config.current.object_id
    }

    cosmosdb_account_managed_identity_read = {
      role_definition_id_or_name = "Key Vault Reader"
      principal_id               = azurerm_cosmosdb_account.this.identity[0].principal_id
    }

    cosmosdb_account_managed_identity = {
      role_definition_id_or_name = "Key Vault Crypto User"   # "Key Vault Crypto Officer" 
      #principal_id = azurerm_cosmosdb_account.this.identity[0].principal_id
      principal_id = azurerm_cosmosdb_account.this.identity[0].principal_id
    }
  }
  #wait_for_rbac = true
}

module "key_vault_key" {
  source  = "app.terraform.io/bokf/key-vault-key/azure"
  version = "< 0.2.0"
  #depends_on = [ module.key_vault_rbac ]

  key_vault_resource_id = module.key_vault.id
  name                  = "${local.cosmosdb_account_name}-encryption"
  type                  = "RSA"
  size                  = "3072"
  opts                  = ["encrypt", "decrypt", "sign", "unwrapKey", "wrapKey"]
  tags                  = var.tags
}


# create a user assigned managed identity (user_assigned_managed_identity is required as cosmosdb supports only UserAssigned identtity for cmk) 
resource "azurerm_user_assigned_identity" "cosmosdb_identity" {
  name = "${local.cosmosdb_account_name}-identity"   #"abcdefgh"  
  location = var.location
  resource_group_name = var.resource_group_name

  depends_on = [ azurerm_cosmosdb_account.this ]
}


=======================================
======================================
## .gitlab-ci.yml


=======================================
======================================
# .terraform-docs.yml



=================================
==================||=========
# CHANGELOG.md


=============================
# CODEOWNERS

=============================
# GETTING_STARTED.md



=================================
==================================
# globals.tf
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "random_integer" "this" {
  min = "100000"
  max = "999999"
}

locals {
  cosmosdb_account_name  = "cdb${var.application_name}${var.tags.environment}${random_integer.this.result}"
  cmk_keyvault_name      = element(split("/", module.key_vault.id), 8)   # module.key_vault.display_name
  key_vault_key_name     = element(split("/", module.key_vault_key.resource_versionless_id), 10)
  normalized_cmk_key_url = "https://${local.cmk_keyvault_name}.vault.azure.net/keys/${local.key_vault_key_name}"

  consistent_prefix_consistency = "ConsistentPrefix"
  continuous_backup_policy      = "Continuous"
  default_geo_location = toset([{
    failover_priority = 0
    zone_redundant    = true
    location          = var.location
  }])
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }

  # managed_identities = {
  #   system_assigned_user_assigned = [ 
  #     {
  #       type = "UserAssigned"
  #       user_assigned_resource_ids = [
  #         azurerm_user_assigned_identity.cosmosdb_identity.id
  #       ]
  #     }

  #   ]
  # }



  normalized_geo_locations             = coalesce(var.geo_locations, local.default_geo_location)
  normalized_cmk_default_identity_type = var.customer_managed_key != null ? "UserAssignedIdentity=${var.customer_managed_key.user_assigned_identity.resource_id}" : null
  periodic_backup_policy               = "Periodic"
  private_endpoint_scope_type          = "PrivateEndpoint"
  serverless_capability                = "EnableServerless"
  #normalized_ip_range_filter           = length(local.trimmed_ip_range_filter) > 0 ? join(",", local.trimmed_ip_range_filter) : null
  normalized_ip_range_filter = length(toset(local.trimmed_ip_range_filter)) > 0 ? join(",", toset(local.trimmed_ip_range_filter)) : null
  trimmed_ip_range_filter    = [for value in var.ip_range_filter : trimspace(value)]

  cmk = {
    #ip_rules                   = []
    virtual_network_subnet_ids = []   # a list of subnet_id [], not a string
  }
  
}

# data "azurerm_cosmosdb_account" "cosmosdb_identity" {
#   name  = azurerm_cosmosdb_account.this.name
#   resource_group_name = var.resource_group_name
# }





==================================
==================================
# main.tf

# The following `main.tf` includes only the core CosmosDB module, without references to specific APIs, making it independent so that separate API modules can be created.
resource "azurerm_cosmosdb_account" "this" {
  name                = local.cosmosdb_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = var.kind == "GlobalDocumentDB" ? "GlobalDocumentDB" : "MongoDB"   # "GlobalDocumentDB"

  is_virtual_network_filter_enabled  = var.is_virtual_network_filter_enabled
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled
  automatic_failover_enabled         = var.automatic_failover_enabled
  multiple_write_locations_enabled   = var.backup.type == local.periodic_backup_policy ? var.multiple_write_locations_enabled : false
  analytical_storage_enabled         = var.analytical_storage_enabled

  default_identity_type                 = local.normalized_cmk_default_identity_type 
  free_tier_enabled                     = var.free_tier_enabled
  ip_range_filter                       = var.ip_range_filter    
  key_vault_key_id                      = local.normalized_cmk_key_url
  local_authentication_disabled         = var.local_authentication_disabled
  minimal_tls_version                   = "Tls12"
  mongo_server_version                  = var.mongo_server_version != null ? var.mongo_server_version : null
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids
  partition_merge_enabled               = var.partition_merge_enabled
  public_network_access_enabled         = var.public_network_access_enabled
  tags                                  = module.tags.tags

  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = var.consistency_policy.consistency_level == local.consistent_prefix_consistency ? var.consistency_policy.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_policy.consistency_level == local.consistent_prefix_consistency ? var.consistency_policy.max_staleness_prefix : null
  }
  dynamic "geo_location" {
    for_each = local.normalized_geo_locations

    content {
      failover_priority = geo_location.value.failover_priority
      location          = geo_location.value.location
      zone_redundant    = geo_location.value.zone_redundant
    }
  }
  dynamic "analytical_storage" {
    for_each = var.analytical_storage_config != null ? [1] : []

    content {
      schema_type = var.analytical_storage_config.schema_type
    }
  }
  backup {
    type                = var.backup.type
    interval_in_minutes = var.backup.type == local.periodic_backup_policy ? var.backup.interval_in_minutes : null
    retention_in_hours  = var.backup.type == local.periodic_backup_policy ? var.backup.retention_in_hours : null
    storage_redundancy  = var.backup.type == local.periodic_backup_policy ? var.backup.storage_redundancy : null
    tier                = var.backup.type == local.continuous_backup_policy ? var.backup.tier : null
  }
  dynamic "capabilities" {
    for_each = var.capabilities

    content {
      name = capabilities.value.name
    }
  }
  capacity {
    total_throughput_limit = var.capacity.total_throughput_limit
  }
  dynamic "cors_rule" {
    for_each = var.cors_rule != null ? [1] : []

    content {
      allowed_headers    = var.cors_rule.allowed_headers
      allowed_methods    = var.cors_rule.allowed_methods
      allowed_origins    = var.cors_rule.allowed_origins
      exposed_headers    = var.cors_rule.exposed_headers
      max_age_in_seconds = var.cors_rule.max_age_in_seconds
    }
  }
  # dynamic "identity" {
  #   for_each = local.managed_identities.system_assigned_user_assigned

  #   content {
  #     type         = identity.value.type   #"UserAssigned"
  #     identity_ids = identity.value.user_assigned_resource_ids   #[azurerm_user_assigned_identity.cosmosdb_identity.id]
  #   }
  # }

  identity {
    type = "UserAssigned"
    #identity_ids = [azurerm_user_assigned_identity.cosmosdb_identity.id]
  }
  
  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules

    content {
      id                                   = virtual_network_rule.value.subnet_id
      ignore_missing_vnet_service_endpoint = false
    }
  }
  lifecycle {
    precondition {
      condition     = var.backup.type == local.continuous_backup_policy && var.multiple_write_locations_enabled ? false : true
      error_message = "Continuous backup mode and multiple write locations cannot be enabled together."
    }
    precondition {
      condition     = var.analytical_storage_enabled && var.partition_merge_enabled ? false : true
      error_message = "Analytical storage and partition merge cannot be enabled together."
    }
    # precondition {
    #   condition     = !(var.public_network_access_enabled && lookup(var.tags, "data_classification", "") != "public")
    #   error_message = "Public network access can only be enabled if the data_classification tag is set to 'Public'."
    # }

    # precondition {
    #   condition     = (var.public_network_access_enabled == true) || (length(var.virtual_network_rules) > 0 || length(var.ip_range_filter) > 0 || var.private_endpoints_enabled)  # (var.public_network_access_enabled == false)
    #   error_message = "When the public network access is disabled, you must provide either virtual network rules, IP range filters, or enable private endpoint."
    # }
  }
  #depends_on = [ azurerm_user_assigned_identity.cosmosdb_identity ]
}


# TO-DO
# resource "time_sleep" "wait_180_seconds_for_destroy" {
#   #count = module.diagnostic_settings.diagnostic_settings_enabled ? 1 : 0   #assuming diagnostic_settings has an output called diagnostic_settings_enabled
#   count = module.enable_diag_settings ? 1 : 0

#   destroy_duration = "180s"
#   triggers = {
#     account_id = azurerm_cosmosdb_account.this.id
#   }
# }

======||
# tags.tf
module "tags" {
  source  = "app.terraform.io/bokf/tag/cloud"
  version = "0.3.2"

  tags = var.tags
}

====||=
variables.encyption.tf
variable "customer_managed_key" {
  type = object({
    key_name              = string
    key_vault_resource_id = string

    key_version = optional(string, null) # Not supported in CosmosDB

    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
  Defaults to `null`. Ignored for Basic and Standard. Defines a customer managed key to use for encryption.

  - `key_name`               - (Required) - The key name for the customer managed key in the key vault.
  - `key_vault_resource_id`  - (Required) - The full Azure Resource ID of the key_vault where the customer managed key will be referenced from.
  - `key_version`            - (Unsupported)

  - `user_assigned_identity` - (Required) - The user assigned identity to use when access the key vault
    - `resource_id`          - (Required) - The full Azure Resource ID of the user assigned identity.

  > Note: Remember to assign permission to the managed identity to access the key vault key. The Key vault used must have enabled soft delete and purge protection. The minimun required permissions is "Key Vault Crypto Service Encryption User"

  Example Inputs:
  ```hcl
  customer_managed_key = {
    key_name               = "sample-customer-key"
    key_vault_resource_id  = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.KeyVault/vaults/{keyVaultName}"
    
    user_assigned_identity {
      resource_id = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{managedIdentityName}"
    }
  }
  ```
  DESCRIPTION

  validation {
    condition     = var.customer_managed_key == null || can(regex("^/subscriptions/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/resourceGroups/.+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.+$", var.customer_managed_key.user_assigned_identity.resource_id))
    error_message = "'user_assigned_identity.resource_id' must be in the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{managedIdentityName}'"
  }

  validation {
    condition     = var.customer_managed_key == null || can(regex("^/subscriptions/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/resourceGroups/.+/providers/Microsoft.KeyVault/vaults/.+$", var.customer_managed_key.key_vault_resource_id))
    error_message = "'key_vault_resource_id' must be in the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.KeyVault/vaults/{keyVaultName}'"
  }

  validation {
    condition     = var.customer_managed_key == null ? true : var.customer_managed_key.key_name != null
    error_message = "'key_name' must have a value"
  }
}

====||
variables.iam.tf

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
  Defaults to `{}`. Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned`            - (Optional) - Defaults to `false`. Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) - Defaults to `[]`. Specifies a set of User Assigned Managed Identity resource IDs to be assigned to this resource.

  Example Inputs:
  ```hcl
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [
      "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{managedIdentityName}"
    ]
  }
  ```
  DESCRIPTION

  validation {
    condition = alltrue([
      for mi_id in var.managed_identities.user_assigned_resource_ids :
      can(regex("^/subscriptions/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/resourceGroups/.+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.+$", mi_id))
    ])
    error_message = "'user_assigned_resource_ids' must be in the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{managedIdentityName}'"
  }
}

###
variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    delegated_managed_identity_resource_id = optional(string, null)

    principal_type    = optional(string, null) # forced to be here by lint, not supported
    condition         = optional(string, null) # forced to be here by lint, not supported
    condition_version = optional(string, null) # forced to be here by lint, not supported
  }))
  default  = {}
  nullable = false

  description = <<DESCRIPTION
  Defaults to `{}`. A map of role assignments to create. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name`             - (Required) - The ID or name of the role definition to assign to the principal.
  - `principal_id`                           - (Required) - The ID of the principal to assign the role to.
  - `description`                            - (Optional) - The description of the role assignment.
  - `skip_service_principal_aad_check`       - (Optional) - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `delegated_managed_identity_resource_id` - (Optional) - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  
  - `principal_type`                         - (Unsupported)
  - `condition`                              - (Unsupported)
  - `condition_version`                      - (Unsupported)

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

  Example Inputs:
  ```hcl
  role_assignments = {
    "key" = {
      skip_service_principal_aad_check = false
      role_definition_id_or_name       = "Contributor"
      description                      = "This is a test role assignment"
      principal_id                     = "eb5260bd-41f3-4019-9e03-606a617aec13"
    }
  }
  ```
  DESCRIPTION

  validation {
    condition = alltrue([
      for k, v in var.role_assignments :
      trimspace(v.role_definition_id_or_name) != null
    ])
    error_message = "'role_definition_id_or_name' must be set and not empty value"
  }

  validation {
    condition = alltrue([
      for k, v in var.role_assignments :
      can(regex("^([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})$", v.principal_id))
    ])
    error_message = "'principal_id' must be a valid GUID"
  }
}

=====||
variables.network.tf
variable "public_network_access_enabled" {
  type        = bool
  nullable    = false
  default     = true # true?
  description = "Defaults to `true`. Whether or not public network access is allowed for this CosmosDB account."
}

variable "network_acl_bypass_for_azure_services" {
  type        = bool
  nullable    = false
  default     = true   #false # No Azure Services can bypass network ACLs for secure environments.
  description = "Defaults to `false`. If Azure services can bypass ACLs."
}

variable "network_acl_bypass_ids" {
  type        = set(string)
  nullable    = false
  default     = []
  description = "Defaults to `[]`. The list of resource Ids for Network Acl Bypass for this Cosmos DB account."
}

variable "ip_range_filter" {
  type        = set(string)
  nullable    = false
  default     = []
  description = <<DESCRIPTION
  Defaults to `[]`. CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for a given database account.

  > Note: To enable the "Allow access from the Azure portal" behavior, you should add the IP addresses provided by the documentation to this list. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal
  > Note: To enable the "Accept connections from within public Azure datacenters" behavior, you should add 0.0.0.0 to the list, see the documentation for more details. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-global-azure-datacenters-or-other-sources-within-azure

  DESCRIPTION

  validation {
    condition = alltrue([
      for value in var.ip_range_filter :
      value == null ? false : strcontains(value, "/") == false || can(cidrhost(value, 0))
    ])
    error_message = "Allowed Ips must be valid IPv4 CIDR."
  }

  validation {
    condition = alltrue([
      for value in var.ip_range_filter :
      value == null ? false : strcontains(value, "/") || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", value))
    ])
    error_message = "Allowed IPs must be valid IPv4."
  }
}

variable "virtual_network_rules" {
  type = set(object({
    subnet_id = string
  }))
  nullable    = false
  default     = []
  description = <<DESCRIPTION
  Defaults to `[]`. Used to define which subnets are allowed to access this CosmosDB account.

  - `subnet_id` - (Required) - The ID of the virtual network subnet.

  > Note: Remember to enable Microsoft.AzureCosmosDB service endpoint on the subnet.

  Example inputs:
  ```hcl
  virtual_network_rule = [
    {
      subnet_id = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}"
    }
  ]
  ```
  DESCRIPTION

  validation {
    condition = alltrue([
      for value in var.virtual_network_rules :
      can(regex("^/subscriptions/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", value.subnet_id))
    ])
    error_message = "'subnet_id' must be in the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}'"
  }
}




==================================
==================================
# outputs.tf
output "display_name" {
  description = "The name of the cosmos db account created."
  value       = azurerm_cosmosdb_account.this.name
}

output "resource_id" {
  description = "The resource ID of the cosmos db account created."
  value       = azurerm_cosmosdb_account.this.id
}

# output "resource_diagnostic_settings" {
#   description = "A map of the diagnostic settings created, with the diagnostic setting name as the key and the diagnostic setting ID as the value."
#   value       = { for diagnostic in azurerm_monitor_diagnostic_setting.this : diagnostic.name => diagnostic.id }
# }



===================================
==================================
# README.md


==================================
==================================
# TERRAFORM_DOCS_INSTRUCTIONS.md


==================================
==================================
# variables.tf
# Required Input Standard Variables 
variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}

variable "application_name" {
  type        = string
  description = "The name of the resource."

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.application_name))
    error_message = "The name must be between 3 and 12 characters, valid characters are lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

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


# Required and Optional Module Specific Input Variables
variable "local_authentication_disabled" {
  type        = bool
  nullable    = false
  default     = true # true??
  description = "Defaults to `false`. Ignored for non SQL APIs accounts. Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Can be set only when using the SQL API."
}

variable "analytical_storage_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. Enable Analytical Storage option for this Cosmos DB account. Enabling and then disabling analytical storage forces a new resource to be created."
}

variable "access_key_metadata_writes_enabled" {
  type        = bool
  default     = false
  description = "Defaults to `false`. Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?"
}

variable "automatic_failover_enabled" {
  type        = bool
  nullable    = false
  default     = true
  description = "Defaults to `true`. Enable automatic failover for this Cosmos DB account."
}

variable "free_tier_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. Enable the Free Tier pricing option for this Cosmos DB account. Defaults to false. Changing this forces a new resource to be created."
}

variable "multiple_write_locations_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. Ignored when `backup.type` is `Continuous`. Enable multi-region writes for this Cosmos DB account."
}

variable "partition_merge_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. Is partition merge on the Cosmos DB account enabled?"
}


### 
variable "consistency_policy" {
  type = object({
    max_interval_in_seconds = optional(number, 5)
    max_staleness_prefix    = optional(number, 100)
    consistency_level       = optional(string, "ConsistentPrefix")
  })
  nullable    = false
  default     = {}
  description = <<DESCRIPTION
  Defaults to `{}`. Used to define the consistency policy for this CosmosDB account

  - `consistency_level`       - (Optional) - Defaults to `ConsistentPrefix`. The Consistency Level to use for this CosmosDB Account - can be either `BoundedStaleness`, `Eventual`, `Session`, `Strong` or `ConsistentPrefix`.
  - `max_interval_in_seconds` - (Optional) - Defaults to `5`. Used when `consistency_level` is set to `BoundedStaleness`. When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. The accepted range for this value is `5` - `86400` (1 day).
  - `max_staleness_prefix`    - (Optional) - Defaults to `100`. Used when `consistency_level` is set to `BoundedStaleness`. When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. The accepted range for this value is `10` – `2147483647`

  Example inputs:
  ```hcl
  consistency_policy = {
    consistency_level       = "ConsistentPrefix"
    max_interval_in_seconds = 10
    max_interval_in_seconds = 100
  }
  ```
  DESCRIPTION

  validation {
    condition     = var.consistency_policy.consistency_level == "ConsistentPrefix" ? var.consistency_policy.max_interval_in_seconds >= 5 && var.consistency_policy.max_interval_in_seconds <= 86400 : true
    error_message = "The 'max_interval_in_seconds' value must be between 5 and 86400 when 'ConsistentPrefix' consistency level is set."
  }

  validation {
    condition     = var.consistency_policy.consistency_level == "ConsistentPrefix" ? var.consistency_policy.max_staleness_prefix >= 10 && var.consistency_policy.max_staleness_prefix <= 2147483647 : true
    error_message = "The 'max_staleness_prefix' value must be between 10 and 2147483647 when 'ConsistentPrefix' consistency level is set."
  }

  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_policy.consistency_level)
    error_message = "The 'consistency_level' value must be one of 'BoundedStaleness', 'Eventual', 'Session', 'Strong' or 'ConsistentPrefix'."
  }
}


variable "geo_locations" {
  type = set(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, true)
  }))
  default     = null
  description = <<DESCRIPTION
  Default to the region where the account was deployed with zone redundant enabled. Specifies a geo_location resource, used to define where data should be replicated with the failover_priority 0 specifying the primary location.

  - `location`          - (Required) - The name of the Azure location where the CosmosDB Account is being created.
  - `failover_priority` - (Required) - The failover priority of the region. A failover priority of 0 indicates a write region.
  - `zone_redundant`    - (Optional) - Defaults to `true`. Whether or not the region is zone redundant.
  
  Example inputs:
  ```hcl
  geo_locations = [
    {
      location          = "eastus"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "westus"
      failover_priority = 1
      zone_redundant    = true
    }
  ]
  ```
  DESCRIPTION
}

variable "backup" {
  type = object({
    retention_in_hours  = optional(number, 8)
    interval_in_minutes = optional(number, 240)
    storage_redundancy  = optional(string, "Geo")
    type                = optional(string, "Continuous")
    tier                = optional(string, "Continuous30Days")
  })
  nullable    = false
  default     = {}
  description = <<DESCRIPTION
  Defaults to `{}`. Configures the backup policy for this Cosmos DB account.

  - `type`                - (Optional) - Defaults to `Continuous`. The type of the backup. Possible values are `Continuous` and `Periodic`
  - `tier`                - (Optional) - Defaults to `Continuous30Days`. Used when `type` is set to `Continuous`. The continuous backup tier. Possible values are `Continuous7Days` and `Continuous30Days`.
  - `interval_in_minutes` - (Optional) - Defaults to `240`. Used when `type` is set to `Periodic`. The interval in minutes between two backups. Possible values are between `60` and `1440`
  - `retention_in_hours`  - (Optional) - Defaults to `8`. Used when `type` is set to `Periodic`. The time in hours that each backup is retained. Possible values are between `8` and `720`
  - `storage_redundancy`  - (Optional) - Defaults to `Geo`. Used when `type` is set to `Periodic`. The storage redundancy is used to indicate the type of backup residency. Possible values are `Geo`, `Local` and `Zone`

  Example inputs:
  ```hcl
  # For Continuous Backup
  backup = {
    type = "Continuous"
    tier = "Continuous30Days"
  }

  # For Periodic Backup
  backup = {
    type                = "Periodic"
    storage_redundancy  = "Geo"
    interval_in_minutes = 240
    retention_in_hours  = 8
  }
  ```
  DESCRIPTION

  validation {
    condition     = var.backup.type == "Continuous" ? contains(["Continuous7Days", "Continuous30Days"], var.backup.tier) : true
    error_message = "The 'tier' value must be 'Continuous7Days' or 'Continuous30Days' when type is 'Continuous'."
  }

  validation {
    condition     = var.backup.type == "Periodic" ? contains(["Geo", "Zone", "Local"], var.backup.storage_redundancy) : true
    error_message = "The 'storage_redundancy' value must be 'Geo', 'Zone' or 'Local' when type is 'Periodic'."
  }

  validation {
    condition     = var.backup.type == "Periodic" ? var.backup.interval_in_minutes >= 60 && var.backup.interval_in_minutes <= 1440 : true
    error_message = "The 'interval_in_minutes' value must be between 60 and 1440 when type is 'Periodic'."
  }

  validation {
    condition     = var.backup.type == "Periodic" ? var.backup.retention_in_hours >= 8 && var.backup.retention_in_hours <= 720 : true
    error_message = "The 'retention_in_hours' value must be between 8 and 720 when type is 'Periodic'."
  }
}

variable "capacity" {
  type = object({
    total_throughput_limit = optional(number, -1)
  })
  nullable    = false
  default     = {}
  description = <<DESCRIPTION
  Defaults to `{}`. Configures the throughput limit for this Cosmos DB account.

  - `total_throughput_limit` - (Optional) - Defaults to `-1`. The total throughput limit imposed on this Cosmos DB account (RU/s). Possible values are at least -1. -1 means no limit.

  Example inputs:
  ```hcl
  capacity = {
    total_throughput_limit = -1
  }
  ```
  DESCRIPTION

  validation {
    condition     = var.capacity.total_throughput_limit >= -1
    error_message = "The 'total_throughput_limit' value must be at least '-1'."
  }
}

variable "analytical_storage_config" {
  type = object({
    schema_type = string
  })
  default     = null
  description = <<DESCRIPTION
  Defaults to `null`. Configuration related to the analytical storage of this account

  - `schema_type` - (Required) - The schema type of the Analytical Storage for this Cosmos DB account. Possible values are FullFidelity and WellDefined.

  Example inputs:
  ```hcl
  analytical_storage_config = {
    schema_type = "WellDefined"
  }
  ```
  DESCRIPTION

  validation {
    condition     = var.analytical_storage_config != null ? contains(["WellDefined", "FullFidelity"], var.analytical_storage_config.schema_type) : true
    error_message = "The 'schema_type' value must be 'WellDefined' or 'FullFidelity'."
  }
}

variable "cors_rule" {
  type = object({
    allowed_headers    = set(string)
    allowed_methods    = set(string)
    allowed_origins    = set(string)
    exposed_headers    = set(string)
    max_age_in_seconds = optional(number, null)
  })
  default     = null
  description = <<DESCRIPTION
  Defaults to `null`. Configures the CORS rule for this Cosmos DB account.

  - `allowed_headers`    - (Required) - A list of headers that are allowed to be a part of the cross-origin request.
  - `allowed_methods`    - (Required) - A list of HTTP headers that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.
  - `allowed_origins`    - (Required) - A list of origin domains that will be allowed by CORS.
  - `exposed_headers`    - (Required) - A list of response headers that are exposed to CORS clients.
  - `max_age_in_seconds` - (Optional) - Defaults to `null`. The number of seconds the client should cache a preflight response. Possible values are between `1` and `2147483647`

  Example inputs:
  ```hcl
  cors_rule = {
    allowed_headers = ["Custom-Header"]
    allowed_methods = ["POST"]
    allowed_origins = ["microsoft.com"]
    exposed_headers = ["Custom-Header"]
    max_age_in_seconds = 100
  }
  ```
  DESCRIPTION

  validation {
    condition = var.cors_rule != null ? alltrue([
      for value in var.cors_rule.allowed_methods :
      contains(["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"], value)
    ]) : true
    error_message = "The 'allowed_methods' value must be 'DELETE', 'GET', 'HEAD', 'MERGE', 'POST', 'OPTIONS', 'PUT' or 'PATCH'."
  }

  validation {
    condition     = var.cors_rule != null ? var.cors_rule.max_age_in_seconds == null || var.cors_rule.max_age_in_seconds >= 1 && var.cors_rule.max_age_in_seconds <= 2147483647 : true
    error_message = "The 'max_age_in_seconds' value if set must be between 1 and 2147483647."
  }
}

variable "capabilities" {
  type = set(object({
    name = string
  }))
  nullable    = false
  default     = []
  description = <<DESCRIPTION
  Defaults to `[]`. The capabilities which should be enabled for this Cosmos DB account.

  - `name` - (Required) - The capability to enable - Possible values are `AllowSelfServeUpgradeToMongo36`, `DisableRateLimitingResponses`, `EnableAggregationPipeline`, `EnableCassandra`, `EnableGremlin`, `EnableMongo`, `EnableMongo16MBDocumentSupport`, `EnableMongoRetryableWrites`, `EnableMongoRoleBasedAccessControl`, `EnablePartialUniqueIndex`, `EnableServerless`, `EnableTable`, `EnableTtlOnCustomPath`, `EnableUniqueCompoundNestedDocs`, `MongoDBv3.4` and `mongoEnableDocLevelTTL`.

  Example inputs:
  ```hcl
  capabilities = [
    {
      name = "DisableRateLimitingResponses"
    }
  ]
  ```
  DESCRIPTION

  validation {
    condition = alltrue([
      for capability in var.capabilities :
      contains(["AllowSelfServeUpgradeToMongo36", "DisableRateLimitingResponses", "EnableAggregationPipeline", "EnableCassandra", "EnableGremlin", "EnableMongo", "EnableMongo16MBDocumentSupport", "EnableMongoRetryableWrites", "EnableMongoRoleBasedAccessControl", "EnablePartialUniqueIndex", "EnableServerless", "EnableTable", "EnableTtlOnCustomPath", "EnableUniqueCompoundNestedDocs", "MongoDBv3.4", "mongoEnableDocLevelTTL"], capability.name)
    ])
    error_message = "The 'name' value must be one of 'AllowSelfServeUpgradeToMongo36', 'DisableRateLimitingResponses', 'EnableAggregationPipeline', 'EnableCassandra', 'EnableGremlin', 'EnableMongo', 'EnableMongo16MBDocumentSupport', 'EnableMongoRetryableWrites', 'EnableMongoRoleBasedAccessControl', 'EnablePartialUniqueIndex', 'EnableServerless', 'EnableTable', 'EnableTtlOnCustomPath', 'EnableUniqueCompoundNestedDocs', 'MongoDBv3.4' or 'mongoEnableDocLevelTTL'."
  }
}

###

# ### Diagnostic modules need to have appropriate  output that indicates diagnostic settings are enabled for this to work.
variable "diagnostic_settings_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. (Optional) Enable CosmosDB diagnostic setting. Valid values are (true, false)."

  validation {
    condition     = can(regex("true|false", var.diagnostic_settings_enabled))
    error_message = "Valid values are true, false."
  }

}


variable "private_endpoints_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. (Optional) Enable Private Endpoint requirement. Valid values are (true, false)."

  validation {
    condition     = can(regex("true|false", var.private_endpoints_enabled))
    error_message = "Valid values are true, false."
  }

}

variable "kind" {
  description = "(Optional) Specifies the kind of CosmosDB to create - possible values are 'GlobalDocumentDB' and 'MongoDB'."
  type = string
  default = "MongoDB"   #"GlobalDocumentDB"
  validation {
    condition = contains(["MongoDB", "GlobalDocumentDB"], var.kind)
    error_message = "Valid values for Cosmosdb kind are (GlobalDocumentDB or MongoDB)."
  }
}


# Optional Standard Variables
variable "is_test_run" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. (Optional) Is this a test run?. Only set to true to use in a test harness to disable certain networking features. Valid values are (true, false)."

}

variable "is_msdn_cosmosdb" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. (Optional) Is this Cosmos Db to be used in an msdn subscription. Valid values are (true, false)."
}

variable "additional_subnet_ids" {
  type        = list(any)
  nullable    = false
  default     = []
  description = "Defaults to `[]`. (Optional) Subnets to be allowed in the firewall to access CosmosDB."
}

variable "is_virtual_network_filter_enabled" {
  type        = bool
  nullable    = false
  default     = true
  description = "Defaults to `false`. (Optional) Enable Virtual network filter_enabled. Valid values are (true, false)"
}

variable "mongo_server_version" {
  type        = string
  default     = null
  description = "Defaults to `null`. (Optional) Mongo Server version if the CosmosDB is intended for MongoDB."
}









==================================
==================================
# versions.tf
# Example versions restriction
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<5.0.0"

    }
    time = {
      source = "hashicorp/time"
      version = "0.12.1"
    }
    random = {}
  }
}



==================================
==================================
==================================
------------------







===========||===================
module "cosmosdb_account" {
  source = "./modules/cosmosdb_account"

  location                         = "East US"
  resource_group_name              = "example-resource-group"
  cosmosdb_name                    = "example-cosmosdb"
  kind                             = "MongoDB"
  enable_private_endpoint          = false
  is_virtual_network_filter_enabled = false
  enable_automatic_failover        = true
  enable_multiple_write_locations = true
  key_vault_name                   = "example-keyvault"
  enable_systemassigned_identity   = true
  zone_redundant                   = true
  failover_location                = "West US"
  failover_zone_redundant          = false
  allowed_origins                  = ["https://example.com"]
  additional_subnet_ids            = []
  capabilities                     = ["EnableCassandra"]
  consistency_level                = "Session"
  max_interval_in_seconds          = 5
  max_staleness_prefix             = 10000
  backup_type                      = "Periodic"
  interval_in_minutes              = 30
  retention_in_hours               = 24
  storage_redundancy               = "GeoRedundant"
}




========================||========================
Gremlin API Example:
# Gremlin API Configuration Example

resource "azurerm_cosmosdb_gremlin_database" "gremlin_db" {
  name                = "gremlin-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_gremlin_graph" "gremlin_graph" {
  name                = "gremlin-graph"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_gremlin_database.gremlin_db.name

  index_policy {
    automatic      = true
    indexing_mode  = "consistent"
    included_paths = ["/*"]
    excluded_paths = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
--------------------------------------
Cassandra API Example
# Cassandra API Configuration Example

resource "azurerm_cosmosdb_cassandra_keyspace" "cassandra_keyspace" {
  name                = "cassandra-keyspace"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
}

resource "azurerm_cosmosdb_cassandra_table" "cassandra_table" {
  name                 = "cassandra-table"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  keyspace_name        = azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspace.name

  schema {
    partition_key {
      name = "id"
    }

    clustering_key {
      name     = "timestamp"
      order_by = "ASC"
    }

    columns {
      name = "id"
      type = "uuid"
    }

    columns {
      name = "timestamp"
      type = "timestamp"
    }

    columns {
      name = "value"
      type = "text"
    }
  }

  throughput = 400
}
---------------------------------
SQL API Example
# SQL API Configuration Example

resource "azurerm_cosmosdb_sql_database" "sql_db" {
  name                = "sql-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_sql_container" "sql_container" {
  name                 = "sql-container"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  database_name        = azurerm_cosmosdb_sql_database.sql_db.name
  partition_key_path   = "/id"
  throughput           = 400

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
-------------------------------------------------
MongoDB API Example
# MongoDB API Configuration Example

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "mongo-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_mongo_collection" "mongo_collection" {
  name                 = "mongo-collection"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  database_name        = azurerm_cosmosdb_mongo_database.mongo_db.name
  partition_key_path   = "/_id"
  throughput           = 400

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
---------------------------------------------
Table API Example
# Table API Configuration Example

resource "azurerm_cosmosdb_table" "table_db" {
  name                = "table-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_table_entity" "table_entity" {
  table_name          = azurerm_cosmosdb_table.table_db.name
  partition_key       = "partitionKey"
  row_key             = "rowKey"
  properties = {
    "property1" = "value1"
    "property2" = "value2"
  }
}
-----------------------------------------------
PostgreSQL API Example
# PostgreSQL API Configuration Example

resource "azurerm_cosmosdb_postgresql_cluster" "postgresql_cluster" {
  name                = "postgresql-cluster"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  administrator_login = var.admin_login
  administrator_password = var.admin_password
  version             = "13"
  sku_name            = "GP_Gen5_2"
  storage_mb          = 5120
  backup_retention_days = 30
  geo_redundant_backup_enabled = true
  tags                = var.tags
}

resource "azurerm_cosmosdb_postgresql_database" "postgresql_db" {
  name                = "postgresql-database"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_postgresql_cluster.postgresql_cluster.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
  throughput          = 400
}

resource "azurerm_cosmosdb_postgresql_table" "postgresql_table" {
  name                = "postgresql-table"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_postgresql_cluster.postgresql_cluster.name
  database_name       = azurerm_cosmosdb_postgresql_database.postgresql_db.name
  schema              = "public"
  columns = [
    { name = "id", type = "SERIAL PRIMARY KEY" },
    { name = "name", type = "VARCHAR(100)" },
    { name = "created_at", type = "TIMESTAMP" }
  ]
  throughput           = 400
}




======================||==========================
========================||========================
# main.tf
---
resource "azurerm_cosmosdb_gremlin_database" "this" {
  name                = var.gremlin_database_name
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = var.database_throughput

  tags = var.tags
}

resource "azurerm_cosmosdb_gremlin_graph" "this" {
  name                = var.gremlin_graph_name
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_gremlin_database.this.name

  index_policy {
    automatic      = true
    indexing_mode  = "consistent"
    included_paths = ["/*"]
    excluded_paths = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}

module "rbac" {
  source = "app.terraform.io/xxxx/common/azure"

  for_each = var.role_assignments

  resource_id   = azurerm_cosmosdb_gremlin_graph.this.id
  resource_name = azurerm_cosmosdb_gremlin_graph.this.name

  role_based_permissions = {
    assignment = {
      role_definition_id_or_name = each.value.role_definition_id_or_name
      principal_id               = each.value.principal_id
    }
  }
  wait_for_rbac = false
}



---
  dynamic "autoscale_settings" {
    for_each = var.enable_autoscale ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }


###=======================================
# globals.tf
---
data "azurerm_client_config" "current" {}

data "azurerm_cosmosdb_account" "this" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name
}





###=======================================
# variables.tf
---
variable "gremlin_database_name" {
  description = "Name of the Gremlin database to create"
  type        = string
}

variable "gremlin_graph_name" {
  description = "Name of the Gremlin graph to create"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group the Cosmos DB account resides in"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "Name of the Cosmos DB account"
  type        = string
}

variable "database_throughput" {
  description = "Throughput for the Gremlin database (e.g., RU/s)"
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
DESCRIPTION
  nullable    = false
}

variable "terraform_module" {
  description = "Used to inform of a parent module"
  type        = string
  default     = ""
}




---
Updated variables.tf (Autoscale Throughput):

variable "enable_autoscale" {
  description = "Flag to enable autoscale throughput"
  type        = bool
  default     = false
}

variable "max_throughput" {
  description = "Maximum throughput for autoscale settings"
  type        = number
  default     = null
}





###=======================================
# outputs.tf
---
output "gremlin_database_id" {
  value       = azurerm_cosmosdb_gremlin_database.this.id
  description = "The ID of the Gremlin database"
}

output "gremlin_graph_id" {
  value       = azurerm_cosmosdb_gremlin_graph.this.id
  description = "The ID of the Gremlin graph"
}




---
### Output Additional Attributes: Include outputs for additional resource details, such as schema and throughput.
output "cassandra_keyspace_throughput" {
  value       = azurerm_cosmosdb_cassandra_keyspace.this.throughput
  description = "The throughput of the Cassandra keyspace"
}

output "cassandra_table_schema" {
  value       = azurerm_cosmosdb_cassandra_table.this.schema
  description = "The schema of the Cassandra table"
}




=====
### Validation Blocks: Add validation blocks for critical variables to prevent misconfigurations.

### Example for partition_key_name.:
variable "partition_key_name" {
  description = "The name of the partition key column"
  type        = string
  validation {
    condition     = contains(var.columns[*].name, var.partition_key_name)
    error_message = "Partition key name must match one of the defined column names."
  }
}



### Example for variable partition_key_name.: 
variable "partition_key_type" {
  description = "The data type of the partition key column (e.g., 'ascii', 'text', 'int')"
  type        = string
  validation {
    condition     = contains(["ascii", "text", "int", "uuid", "timestamp"], var.partition_key_type)
    error_message = "Partition key type must be a valid Cassandra type (e.g., 'ascii', 'text', 'int')."
  }
}




╵=============================||=================================================
The cosmosdb_cassandra_database module is designed specifically to create and manage Cosmos DB Cassandra API databases. This module adheres to the new design principles and integrates seamlessly with the foundational module cosmosdb_account_common, which serves as a flexible and reusable base for implementing Cosmos DB accounts for Cassandra and other API databases.

Key Features:
Simplifies the deployment and configuration of Cassandra API databases within a Cosmos DB account.
Leverages cosmosdb_account_common for centralized configurations, including consistency policies, geo-replication, network security, and tagging.
Promotes modularity, enabling independent scaling and management of Cassandra API databases.

Integration:
This module is designed to operate in conjunction with the cosmosdb_account_common foundational module. Ensure the foundational module is deployed and configured to establish consistent settings across all API databases while maintaining the flexibility to tailor Cassandra-specific requirements.

Planned updates include support for advanced features such as dynamic throughput scaling, enhanced diagnostic integration, and additional security configurations, aligned with improvements in the foundational module.

--------------------------------------------------
The cosmosdb_postgresql_database module is designed specifically to create and manage Cosmos DB PostgreSQL API databases. This module aligns with the new design approach and integrates seamlessly with the foundational module cosmosdb_account_common, which serves as a flexible and reusable base for implementing Cosmos DB accounts for PostgreSQL and other API databases.

Key Features:
Simplifies the deployment and management of PostgreSQL API databases within a Cosmos DB account.
Utilizes cosmosdb_account_common for shared configurations such as consistency policies, geo-replication, network security, and tagging.
Ensures modularity, enabling independent configuration and scaling of PostgreSQL API databases.

Integration:
This module is intended to work alongside the cosmosdb_account_common foundational module. Ensure the foundational module is deployed and properly configured to maintain consistent account-level settings while providing flexibility for PostgreSQL-specific database needs.

Future enhancements will include advanced features such as dynamic throughput scaling, enhanced diagnostic settings, and additional security measures, in line with updates to the foundational module.
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
