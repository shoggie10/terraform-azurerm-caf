locals {
  # These are the various naming standards
  tfModule          = "Example"                                                                                       ## This should be the service name please update without fail and do not remove these two definitions.
  tfModule_extended = var.terraform_module != "" ? join(" ", [var.terraform_module, local.tfModule]) : local.tfModule ## This is to send multiple tags if the main module have submodule calls.
}

resource "azurerm_cosmosdb_table" "this" {
  name                = var.table_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  resource_group_name = var.resource_group_name

  autoscale_settings {
    max_throughput = var.table_max_throughput
  }
}

module "rbac" {
  source = "app.terraform.io/bokf/common/azure"

  for_each = var.role_assignments
  depends_on = [azurerm_cosmosdb_table.this]

  resource_id   = azurerm_cosmosdb_table.this.id
  resource_name = azurerm_cosmosdb_table.this.name

  role_based_permissions = {
    assignment = {
      role_definition_id_or_name = each.value.role_definition_id_or_name
      principal_id               = each.value.principal_id
    }
  }
  wait_for_rbac = false
}
