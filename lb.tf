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

Error: checking for presence of existing Key "cdbwaynetechhubdev843060-encryption" (Key Vault "https://kv-0000-cosmosd-dev-760.vault.azure.net/"): keyvault.BaseClient#GetKey: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="Forbidden" Message="Client address is not authorized and caller is not a trusted service.\r\nClient address: 165.225.37.25\r\nCaller: appid=04b07795-8ddb-461a-bbee-02f9e1bf7b46;oid=730ce96a-7db7-4204-9611-4851956b3076;iss=https://sts.windows.net/e7066c90-b459-44c5-91f1-3581f3d1f082/\r\nVault: kv-0000-cosmosd-dev-760;location=eastus" InnerError={"code":"ForbiddenByFirewall"}
│ 
│   with module.this.module.key_vault_key.azurerm_key_vault_key.this,
│   on .terraform/modules/this.key_vault_key/main.tf line 1, in resource "azurerm_key_vault_key" "this":
│    1: resource "azurerm_key_vault_key" "this" {

Firewall is turned on and your client IP address is not authorized to access this key vault.
 

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






==================================
==================================
# main.tf



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
