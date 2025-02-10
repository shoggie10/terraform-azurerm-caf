variable "table_name" {
  description = "Name of the CosmosDB Table to create"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "The name of the CosmosDB account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "table_max_throughput" {
  description = "The maximum throughput for autoscale settings"
  type        = number
  default     = 400
}

variable "table_throughput" {
  description = "The throughput for the table. If null, the table will be autoscaled."
  type        = number
  default     = null
  validation {
    condition     = var.table_throughput >= 400
    error_message = "Table throughput must be a positive number greater than or equal to 400."
  }
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

###
# variable "throughput_validation" {
#   description = "Validates that only one of throughput or max_throughput is set"
#   default     = null
#   validation {
#     condition     = length(compact(local.throughput_settings)) == 1
#     error_message = "You must specify either 'throughput' or 'max_throughput', not both."
#   }
# }
