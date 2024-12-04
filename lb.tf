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
========================||========================
╷
│ Error: Invalid index
│ 
│   on ../customer-managed-key.tf line 41, in module "key_vault_rbac":
│   41:       principal_id               = azurerm_cosmosdb_account.this.identity[0].principal_id
│     ├────────────────
│     │ azurerm_cosmosdb_account.this.identity is empty list of object
│ 
│ The given key does not identify an element in this collection value: the collection has no elements.
╵
╷
│ Error: Invalid index
│ 
│   on ../customer-managed-key.tf line 46, in module "key_vault_rbac":
│   46:       principal_id = azurerm_cosmosdb_account.this.identity[0].principal_id
│     ├────────────────
│     │ azurerm_cosmosdb_account.this.identity is empty list of object
│ 
│ The given key does not identify an element in this collection value: the collection has no elements.

======================||==========================
========================||========================
# main.tf
---
resource "azurerm_cosmosdb_postgresql_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  administrator_login = var.administrator_login
  administrator_password = var.administrator_password
  version             = var.postgresql_version
  sku_name            = var.sku_name
  storage_mb          = var.storage_mb
  backup_retention_days = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  tags                = var.tags
#  autoscale_settings {
#   max_throughput = var.autoscale_max_throughput
#  }
  dynamic "geo_redundant_backup_enabled" {
    for_each = var.enable_geo_redundant_backup ? [1] : []
    content {
      enabled = true
    }
  }

dynamic "autoscale_settings" {
  for_each = var.autoscale_max_throughput != null ? [1] : []
  content {
    max_throughput = var.autoscale_max_throughput
  }
}

}

resource "azurerm_cosmosdb_postgresql_database" "this" {
  name                = var.database_name
  cluster_id          = azurerm_cosmosdb_postgresql_cluster.this.id
  charset             = var.database_charset
  collation           = var.database_collation
}

module "rbac" {
  source = "app.terraform.io/xxxx/common/azure"

  for_each = var.role_assignments

  resource_id   = azurerm_cosmosdb_postgresql_database.this.id
  resource_name = azurerm_cosmosdb_postgresql_database.this.name

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
    for_each = var.max_throughput != null ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
###=======================================
# globals.tf
---
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}


###=======================================
# variables.tf
---
variable "cluster_name" {
  description = "Name of the CosmosDB PostgreSQL cluster to create"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}

variable "administrator_login" {
  description = "The administrator login name for the PostgreSQL cluster"
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL cluster"
  type        = string
  sensitive   = true
}

variable "postgresql_version" {
  description = "The version of PostgreSQL to use (e.g., 13)"
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL cluster (e.g., GP_Gen5_2)"
  type        = string
}

variable "storage_mb" {
  description = "The maximum storage for the PostgreSQL cluster in megabytes"
  type        = number
}

variable "backup_retention_days" {
  description = "The number of days to retain backups"
  type        = number
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backup is enabled"
  type        = bool
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "database_name" {
  description = "The name of the PostgreSQL database to create"
  type        = string
}

variable "database_charset" {
  description = "The charset for the PostgreSQL database"
  type        = string
  default     = "UTF8"
}

variable "database_collation" {
  description = "The collation for the PostgreSQL database"
  type        = string
  default     = "en_US.UTF8"
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
variable "autoscale_max_throughput" {
  description = "Maximum throughput for autoscaling"
  type        = number
  default     = null
}




###=======================================
# outputs.tf
---
output "postgresql_cluster_id" {
  value       = azurerm_cosmosdb_postgresql_cluster.this.id
  description = "The ID of the CosmosDB PostgreSQL cluster"
}

output "postgresql_database_id" {
  value       = azurerm_cosmosdb_postgresql_database.this.id
  description = "The ID of the PostgreSQL database"
}

---
### Expose Additional Outputs: Include outputs for important attributes, such as the PostgreSQL cluster's FQDN or connection string.
output "postgresql_cluster_fqdn" {
  value       = azurerm_cosmosdb_postgresql_cluster.this.fully_qualified_domain_name
  description = "The fully qualified domain name of the PostgreSQL cluster"
}


=====
### Add Validation for Variables: Use validation blocks to enforce correct input values.

### Example for postgresql_version:
variable "postgresql_version" {
  description = "The version of PostgreSQL to use (e.g., 13)"
  type        = string
  validation {
    condition     = contains(["12", "13", "14"], var.postgresql_version)
    error_message = "Supported PostgreSQL versions are: 12, 13, 14."
  }
}
### Example for administrator_password
variable "administrator_password" {
  description = "The administrator password for the PostgreSQL cluster"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.administrator_password) >= 8
    error_message = "Password must be at least 8 characters long."
  }
}

╵=============================||=================================================


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
