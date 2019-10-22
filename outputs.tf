output "resource_group_name" {
  value = "${azurerm_postgresql_server.server.resource_group_name}"
}

output "server_name" {
  value = "${azurerm_postgresql_server.server.name}"
}


output "fqdn" {
  value = "${azurerm_postgresql_server.server.fqdn}"
}