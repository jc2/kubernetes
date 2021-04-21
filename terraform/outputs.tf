output "acr_server" {
  value = azurerm_container_registry.acr.login_server
}

output "db_server" {
  value = azurerm_postgresql_server.db_server.fqdn
}

output "broker_server" {
  value = azurerm_redis_cache.broker.hostname
}

output "broker_password" {
  value = azurerm_redis_cache.broker.primary_access_key
  sensitive = true
}

output "files_account_primary_key" {
  value = azurerm_storage_account.files_account.primary_access_key
  sensitive = true
}

output "files_account_primary_connection" {
  value = azurerm_storage_account.files_account.primary_connection_string
  sensitive = true
}