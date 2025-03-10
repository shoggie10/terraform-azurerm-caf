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
====================||===========

https://us05web.zoom.us/j/85932844066?pwd=b2rodACYp8qIs1UBsnTcp1eH8JDbvN.1





=================||


=====||====





=====||===







=========





======||===

-----\\---





-----------------------------------------------------

## examples








================================||
# customer-managed-key.tf
# module "key_vault" {
#   source  = "app.terraform.io/xxxx/key-vault/azure"
#   version = "< 0.2.0"

#   application_name                = "cosmosdbcmk"  
#   enabled_for_template_deployment = true
#   resource_group_name             = var.resource_group_name

#   network_acls = {
#     # Bypass must be set to AzureServices for CosmosDB CMK usage when not using Private Endpoints
#     bypass = length(var.private_endpoints) != 0 ? "None" : "AzureServices"
#     # Set to allow only if no PE, IP Rules, or VNet rules exist.
#     default_action             = length(var.private_endpoints) == 0 && length(var.ip_range_filter) == 0 && length(local.cmk.virtual_network_subnet_ids) == 0 ? "Allow" : "Deny"
#     ip_rules                   = var.ip_range_filter
#     virtual_network_subnet_ids = local.cmk.virtual_network_subnet_ids
#   }

#   tags = var.tags
# }


# module "key_vault_rbac" {
#   source  = "app.terraform.io/xxxx/common/azure"
#   #version = "< 0.2.0"
#   resource_name = module.key_vault.display_name
#   resource_id = module.key_vault.id

#   #depends_on = [azurerm_cosmosdb_account.this]


#   role_based_permissions = {
#     terraform = {
#       role_definition_id_or_name = "Key Vault Administrator" # "Key Vault Contributor" 
#       principal_id = data.azurerm_client_config.current.object_id
#     }

#     cosmosdb_account_managed_identity_read = {
#       role_definition_id_or_name = "Key Vault Reader"
#       principal_id               = azurerm_cosmosdb_account.this.identity[0].principal_id
#     }

    

#     cosmosdb_account_managed_identity = {
#       role_definition_id_or_name = "Key Vault Crypto User"   # "Key Vault Crypto Officer" 
#       #principal_id = azurerm_cosmosdb_account.this.identity[0].principal_id
#       principal_id = azurerm_cosmosdb_account.this.identity[0].principal_id
#     }
#   }
#   #wait_for_rbac = true
# }

# module "key_vault_key" {
#   source  = "app.terraform.io/xxxx/key-vault-key/azure"
#   version = "< 0.2.0"
#   #depends_on = [ module.key_vault_rbac ]

#   key_vault_resource_id = module.key_vault.id
#   name                  = "${local.cosmosdb_account_name}-encryption"
#   type                  = "RSA"
#   size                  = "3072"
#   opts                  = ["encrypt", "decrypt", "sign", "unwrapKey", "wrapKey"]
#   tags                  = var.tags
# }


# # create a user assigned managed identity (user_assigned_managed_identity is required as cosmosdb supports only UserAssigned identtity for cmk) 
# resource "azurerm_user_assigned_identity" "cosmosdb_identity" {
#   name = "${local.cosmosdb_account_name}-identity"   #"abcdefgh"  
#   location = var.location
#   resource_group_name = var.resource_group_name

#   depends_on = [ azurerm_cosmosdb_account.this ]
# }


###
# resource "azurerm_role_assignment" "key_vault_access" {
#   scope                = azurerm_key_vault.this.id # Or the appropriate scope
#   role_definition_name = "Key Vault Secrets User" # Or "Key Vault Crypto User"
#   principal_id         = "730ce96a-7db7-4204-9611-4851956b3076"
# }


#################
# Create the Key Vault
module "key_vault" {
  source  = "app.terraform.io/xxxx/key-vault/azure"
  version = "< 0.2.0"

  application_name                = "cosmosdbcassandra"
  enabled_for_template_deployment = true
  resource_group_name             = var.resource_group_name

  network_acls = {
    bypass                       = length(var.private_endpoints) != 0 ? "None" : "AzureServices"
    default_action               = length(var.private_endpoints) == 0 && length(var.ip_range_filter) == 0 && length(local.cmk.virtual_network_subnet_ids) == 0 ? "Allow" : "Deny"
    ip_rules                     = var.ip_range_filter
    virtual_network_subnet_ids   = local.cmk.virtual_network_subnet_ids
  }

  tags = var.tags
}

# Create the Cosmos DB account's managed identity
resource "azurerm_user_assigned_identity" "cosmosdb_identity" {
  name                = "${local.cosmosdb_account_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Assign RBAC roles for the Key Vault
module "key_vault_rbac" {
  source  = "app.terraform.io/xxxx/common/azure"
  resource_name = module.key_vault.display_name
  resource_id   = module.key_vault.id

  role_based_permissions = {
    terraform = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }

    cosmosdb_account_managed_identity_read = {
      role_definition_id_or_name = "Key Vault Reader"
      principal_id               = azurerm_user_assigned_identity.cosmosdb_identity.principal_id
    }

    cosmosdb_account_managed_identity = {
      role_definition_id_or_name = "Key Vault Crypto User"
      principal_id               = azurerm_user_assigned_identity.cosmosdb_identity.principal_id
    }
  }
}

# RBAC role assignments to propagate
resource "time_sleep" "wait_for_rbac" {
  depends_on = [module.key_vault_rbac]

  create_duration = "30s"
}

# Create the Key Vault Key
module "key_vault_key" {
  source  = "app.terraform.io/xxxx/key-vault-key/azure"
  version = "< 0.2.0"

  #depends_on = [time_sleep.wait_for_rbac]

  key_vault_resource_id = module.key_vault.id
  name                  = "${local.cosmosdb_account_name}-encryption"
  type                  = "RSA"
  size                  = 3072
  opts                  = ["encrypt", "decrypt", "sign", "unwrapKey", "wrapKey"]
  tags                  = var.tags
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

  consistent_prefix_consistency = "ConsistentPrefix"   #"Session"
  continuous_backup_policy      = "Continuous"
  default_geo_location = toset([{
    failover_priority = 0
    zone_redundant    = true
    location          = var.location
  }])

  # Ensure the User-Assigned Managed Identity is correctly referenced
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

  normalized_geo_locations             = coalesce(var.geo_locations, local.default_geo_location)
  #normalized_cmk_default_identity_type = var.customer_managed_key != null ? "UserAssignedIdentity=${var.customer_managed_key.user_assigned_identity.resource_id}" : null
  normalized_cmk_default_identity_type = "UserAssignedIdentity=${azurerm_user_assigned_identity.cosmosdb_identity.id}"

  periodic_backup_policy               = "Periodic"
  private_endpoint_scope_type          = "PrivateEndpoint"
  serverless_capability                = "EnableServerless"
  normalized_ip_range_filter           = length(toset(local.trimmed_ip_range_filter)) > 0 ? join(",", toset(local.trimmed_ip_range_filter)) : null
  trimmed_ip_range_filter              = [for value in var.ip_range_filter : trimspace(value)]

  cmk = {
    virtual_network_subnet_ids = []   # a list of subnet_id [], not a string
  }

  ###
  capability_names = [for cap in var.capabilities : cap.name]

  # Determine kind based on capabilities
  kind = contains(local.capability_names, "EnableCassandra") ? "GlobalDocumentDB" : "MongoDB"

  backup_type = local.kind == "MongoDB" ? "Continuous" : "Periodic"
}







==================================
==================================
# main.tf

resource "azurerm_cosmosdb_account" "this" {
  name                               = local.cosmosdb_account_name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  offer_type                         = "Standard"
  kind                               = "GlobalDocumentDB"   #var.api_type !="" ? var.api_type : "GlobalDocumentDB"
  #kind                               = lookup(var.database_settings[var.selected_db], "kind", "GlobalDocumentDB")


  is_virtual_network_filter_enabled  = var.is_virtual_network_filter_enabled
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled
  automatic_failover_enabled         = var.automatic_failover_enabled
  multiple_write_locations_enabled   = var.backup.type == local.periodic_backup_policy ? var.multiple_write_locations_enabled : false
  analytical_storage_enabled         = var.analytical_storage_enabled

  default_identity_type                 = "UserAssignedIdentity=${azurerm_user_assigned_identity.cosmosdb_identity.id}"
  ip_range_filter                       = var.ip_range_filter
  key_vault_key_id                      = local.normalized_cmk_key_url
  
  minimal_tls_version                   = "Tls12"
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids
  public_network_access_enabled         = var.public_network_access_enabled
  tags = module.tags.tags


  #free_tier_enabled                     = var.free_tier_enabled
  #partition_merge_enabled               = var.partition_merge_enabled
  #local_authentication_disabled         = var.local_authentication_disabled
  

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

  # dynamic "analytical_storage" {
  #   for_each = var.analytical_storage_config != null ? [1] : []

  #   content {
  #     schema_type = var.analytical_storage_config.schema_type
  #   }
  # }
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

  # dynamic "capabilities" {
  #   for_each = lookup(var.database_settings[var.selected_db], "capabilities", [])
  #   content {
  #     name = capabilities.value
  #   }
  # }


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

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cosmosdb_identity.id]
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

    # precondition {
    #   condition     = var.analytical_storage_enabled && var.partition_merge_enabled ? false : true
    #   error_message = "Analytical storage and partition merge cannot be enabled together."
    # }
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


======||
# tags.tf

====||=
variables.encyption.tf


====||


=====||
variables.network.tf





==================================
==================================
# outputs.tf




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


# # Required and Optional Module Specific Input Variables
# variable "local_authentication_disabled" {
#   type        = bool
#   nullable    = false
#   default     = false # true??
#   description = "Defaults to `false`. Ignored for non SQL APIs accounts. Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Can be set only when using the SQL API."
# }

variable "analytical_storage_enabled" {
  type        = bool
  nullable    = false
  default     = false
  description = "Defaults to `false`. Enable Analytical Storage option for this Cosmos DB account. Enabling and then disabling analytical storage forces a new resource to be created."
}


variable "automatic_failover_enabled" {
  type        = bool
  nullable    = false
  default     = true
  description = "Defaults to `true`. Enable automatic failover for this Cosmos DB account."
}

variable "access_key_metadata_writes_enabled" {
  type        = bool
  default     = false
  description = "Defaults to `false`. Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?"
}


# variable "free_tier_enabled" {
#   type        = bool
#   nullable    = false
#   default     = false
#   description = "Defaults to `false`. Enable the Free Tier pricing option for this Cosmos DB account. Defaults to false. Changing this forces a new resource to be created."
# }

# variable "multiple_write_locations_enabled" {
#   type        = bool
#   nullable    = false
#   default     = false
#   description = "Defaults to `false`. Ignored when `backup.type` is `Continuous`. Enable multi-region writes for this Cosmos DB account."
# }

# variable "partition_merge_enabled" {
#   type        = bool
#   nullable    = false
#   default     = false
#   description = "Defaults to `false`. Is partition merge on the Cosmos DB account enabled?"
# }


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
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_policy.consistency_level)
    error_message = "The 'consistency_level' value must be one of 'BoundedStaleness', 'Eventual', 'Session', 'Strong' or 'ConsistentPrefix'."
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
    # type                = optional(string, "Continuous")
    # tier                = optional(string, "Continuous30Days")
    type                = optional(string, "Periodic")
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
  default = "GlobalDocumentDB"
  validation {
    condition = contains(["GlobalDocumentDB"], var.kind)   #(["MongoDB", "GlobalDocumentDB"], var.kind)
    error_message = "Valid values for Cosmosdb kind are (GlobalDocumentDB or MongoDB)."
  }
}

# variable "database_settings" {
#   description = "(Optional) Supported API for the databases in the account and a list of databases to provision. Allowed values of API type are Sql, Cassandra, MongoDB, Gremlin, Table. If 'use_autoscale' is set, 'throughput' becomes 'max_throughput' with a minimum value of 1000."
#   type = object({
#     api_type = string
#     databases = list(object({
#       name          = string
#       throughput    = number
#       use_autoscale = bool #If this is set, throughput will become max_throughput
#     }))
#   })
#   default = {
#     api_type  = "Cassandra"
#     databases = []
#   }
#   validation {
#     condition     = contains(["Cassandra", "Gremlin", "Table", "Postgresql"], var.database_settings.api_type)
#     error_message = "Valid values for database API type are (Cassandra, Gremlin, Table, and Postgresql)."
#   }
# }

# variable "database_settings" {
#   type = map(any)
#   default = {
#     "Cassandra" = {
#       kind        = "GlobalDocumentDB"
#       capabilities = ["EnableCassandra"]
#     }
#     "Gremlin" = {
#       kind        = "GlobalDocumentDB"
#       capabilities = ["EnableGremlin"]
#     }
#   }
# }

# variable "api_type" {
#   description = "The API type to use for the Cosmos DB account (Cassandra, Gremlin, Table, and Postgresql)"
#   type = string
#   default = "Cassandra"
# }

# variable "selected_db" {
#   description = "The type of database to enable (Cassandra, Gremlin, MongoDB, SQL)"
#   type        = string
#   default     = "Cassandra"
# }

# variable "database_throughput" {
#   description = "(Optional) RU throughput value for the selected database."
#   type        = number
#   default     = 400
# }


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




# Optional Standard Variables
# variable "is_test_run" {
#   type        = bool
#   nullable    = false
#   default     = false
#   description = "Defaults to `false`. (Optional) Is this a test run?. Only set to true to use in a test harness to disable certain networking features. Valid values are (true, false)."

# }

# variable "is_msdn_cosmosdb" {
#   type        = bool
#   nullable    = false
#   default     = false
#   description = "Defaults to `false`. (Optional) Is this Cosmos Db to be used in an msdn subscription. Valid values are (true, false)."
# }

# variable "additional_subnet_ids" {
#   type        = list(any)
#   nullable    = false
#   default     = []
#   description = "Defaults to `[]`. (Optional) Subnets to be allowed in the firewall to access CosmosDB."
# }

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



variable "enable_automatic_failover" {
  description = "(Optional) Enable automatic failover for this Cosmos DB account. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_automatic_failover))
    error_message = "Valid values are true, false."
  }
}

variable "multiple_write_locations_enabled" {
  description = "(Optional) Enable multiple write locations for this Cosmos DB account. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.multiple_write_locations_enabled))
    error_message = "Valid values are true, false."
  }
}

variable "enable_replication" {
  description = "(Optional) Enable replication of this Cosmos DB account to a secondary location. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_replication))
    error_message = "Valid values are true, false."
  }
}

variable "failover_zone_redundant" {
  description = "(Optional) Should Zone Redundancy in the failover region be enabled?"
  type        = bool
  default     = false
}

variable "failover_location" {
  description = "(Optional) The name of the Azure region to host replicated data. Valid values are (eastus2, centralus)."
  type        = string
  default     = ""
  validation {
    condition     = contains(["", "eastus2", "centralus"], var.failover_location)
    error_message = "Valid values for failover_location are (eastus and centralus)."
  }
}

variable "failover_priority" {
  description = "(Optional) The failover priority of the region. A failover priority of 0 indicates a write region."
  type        = string
  default     = "0"
}

variable "zone_redundant" {
  description = "(Optional) Should Zone Redundancy in the primary region be enabled?"
  type        = bool
  default     = false
}

variable "allowed_origins" {
  description = <<EOT
  (Optional) Configures the allowed origins for this Cosmos DB account in CORS Feature:
  A list of origin domains that will be allowed by CORS.
  EOT
  type        = list(string)
  default     = []
}

variable "max_staleness_prefix" {
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647."
  type        = string
  default     = "10"
}

variable "max_interval_in_seconds" {
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day)."
  type        = string
  default     = "5"
}

variable "interval_in_minutes" {
  description = "(Optional) The interval in minutes between two backups. This is configurable only when type is Periodic. Possible values are between 60 and 1440."
  type        = number
  default     = 60
  validation {
    condition     = var.interval_in_minutes >= 60 && var.interval_in_minutes <= 1440 && floor(var.interval_in_minutes) == var.interval_in_minutes
    error_message = "Accepted values in between (minutes): 60 - 1440."
  }
}

variable "retention_days" {
  description = "(Optional) Cosmosdb retention daysl[Provide retention days if 'enable_diagnostics' is set to true]"
  default     = 7
}

variable "retention_in_hours" {
  description = "(Optional) The time in hours that each backup is retained. This is configurable only when type is Periodic. Possible values are between 8 and 720."
  type        = number
  default     = 8
  validation {
    condition     = var.retention_in_hours >= 8 && var.retention_in_hours <= 720 && floor(var.retention_in_hours) == var.retention_in_hours
    error_message = "Accepted values in between (hours): 8 - 720."
  }
}

variable "storage_redundancy" {
  description = "(Optional) The storage redundancy is used to indicate the type of backup residency. This is configurable only when type is Periodic. Possible values are Geo, Local and Zone."
  type        = string
  default     = "Local"
  validation {
    condition     = contains(["Geo", "Local", "Zone"], var.storage_redundancy)
    error_message = "Valid values for storage_redundancy are (Geo, Local and Zone)."
  }
}

variable "user_assigned_identity_ids" {
  description = "List of User Assigned Managed Identity IDs to be used with the Cosmos DB account."
  type = list(string)
  default = []
}

# variable "is_virtual_network_filter_enabled" {
#   description = "Is this cosmos db to be used in an msdn subscription. Default is false."
#   type        = bool
#   default     = true
# }







==================================
==================================
# versions.tf




==================================
==================================
==================================
------------------







===========||===================
module "cosmosdb_account" {




========================||========================
Gremlin API Example:

--------------------------------------
Cassandra API Example

---------------------------------
SQL API Example

-------------------------------------------------
MongoDB API Example

---------------------------------------------
Table API Example

-----------------------------------------------
PostgreSQL API Example



======================||==========================
========================||========================
# main.tf



---



###=======================================
# globals.tf
---






###=======================================
# variables.tf
---


---





###=======================================
# outputs.tf
---




---
### Output Additional Attributes: Include outputs for additional resource details, such as schema and throughput.




=====
### Validation Blocks: Add validation blocks for critical variables to prevent misconfigurations.








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
