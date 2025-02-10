data "azurerm_client_config" "current" {}

data "azurerm_cosmosdb_account" "this" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name
}

locals {
  table_throughput = var.table_throughput != null ? var.table_throughput : var.table_max_throughput
}
