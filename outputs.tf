output "cosmosdb_table_id" {
  description = "The ID of the Cosmos DB Table."
  value       = azurerm_cosmosdb_table.this.id
}

output "cosmosdb_table_name" {
  description = "The ID of the Cosmos DB Table."
  value       = azurerm_cosmosdb_table.this.name
}
