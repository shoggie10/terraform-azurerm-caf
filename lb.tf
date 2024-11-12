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
  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [var.network_rules]

    content {
      default_action = var.tags.data_classification == "Public" && network_rules.value.default_action == "Allow" ? "Allow" : "Deny"
      bypass         = network_rules.value.bypass

      ip_rules = var.tags.data_classification == "Public" && network_rules.value.default_action == "Allow" ? [] : (
        var.network_rules.private_link_access == null ? (
          length(network_rules.value.virtual_network_subnet_ids) == 0 ? network_rules.value.ip_rules : []
        ) : []
      )

      virtual_network_subnet_ids = var.tags.data_classification == "Public" && network_rules.value.default_action == "Allow" ? [] : (
        var.network_rules.private_link_access == null ? (
          length(network_rules.value.ip_rules) == 0 ? network_rules.value.virtual_network_subnet_ids : []
        ) : []
      )

      dynamic "private_link_access" {
        for_each = var.network_rules.private_link_access == null ? [] : var.network_rules.private_link_access

        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
        }
      }
    }
  }
---
module "key_vault" {
  source  = "app.terraform.io/xxxx/key-vault/azure"
  version = "< 0.2.0"

  application_name                = "storcmk"
  enabled_for_template_deployment = true
  resource_group_name             = var.resource_group_name

  network_acls = {
    #Bypass must be set to AzureServices for Storage Account CMK usage when not using Private Endpoints
    bypass = length(var.private_endpoints) != 0 ? "None" : "AzureServices"
    #Set to allow only if no PE, IP Rules, or VNet rules exist.
    default_action             = length(var.private_endpoints) == 0 && length(local.cmk.ip_rules) == 0 && length(local.cmk.virtual_network_subnet_ids) == 0 ? "Allow" : "Deny"
    ip_rules                   = local.cmk.ip_rules
    virtual_network_subnet_ids = local.cmk.virtual_network_subnet_ids
  }

  tags = var.tags
}

module "key_vault_rbac" {
  source  = "app.terraform.io/xxxx/common/azure"
  version = "< 0.2.0"
  #source = "../terraform-azure-common"
  resource_name = module.key_vault.display_name
  resource_id   = module.key_vault.id

  role_based_permissions = {
    terraform = {
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    storage_account_managed_identity_read = {
      role_definition_id_or_name = "Key Vault Reader"
      principal_id               = azurerm_storage_account.this.identity[0].principal_id
    }
    storage_account_managed_identity = {
      role_definition_id_or_name = "Key Vault Crypto User"
      principal_id               = azurerm_storage_account.this.identity[0].principal_id
    }
  }
}

module "key_vault_key" {
  source     = "app.terraform.io/bxxx/key-vault-key/azure"
  version    = "< 0.2.0"
  depends_on = [module.key_vault_rbac]

  key_vault_resource_id = module.key_vault.id
  name                  = "${azurerm_storage_account.this.name}-encryption"
  type                  = "RSA"
  size                  = "2048"
  opts                  = ["encrypt", "decrypt", "sign", "unwrapKey", "wrapKey"]
  tags                  = var.tags
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  depends_on = [module.key_vault_key]

  #By not binding to a specific version reference of the key, the newest key is always used
  #Otherwise, version must be updated via terraform 
  key_name           = "${azurerm_storage_account.this.name}-encryption"
  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = module.key_vault.id

  lifecycle {
    precondition {
      condition     = (var.account_kind == "StorageV2" || var.account_tier == "Premium")
      error_message = "`var.customer_managed_key` can only be set when the `account_kind` is set to `StorageV2` or `account_tier` set to `Premium`."
    }
  }
}
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
