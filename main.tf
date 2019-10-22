resource "azurerm_resource_group" "db" {
  name     = "${var.name}"
  location = "${var.location}"
}

resource "azurerm_postgresql_server" "server" {
  name                = "${azurerm_resource_group.db.name}"
  location            = "${azurerm_resource_group.db.location}"
  resource_group_name = "${azurerm_resource_group.db.name}"

  sku {
    name     = "${lookup(var.db, "sku_name", "B_Gen5_1")}"
    capacity = "${lookup(var.db, "sku_capacity", 1)}"
    tier     = "${lookup(var.db, "sku_tier", "Basic")}"
    family   = "${lookup(var.db, "sku_family", "Gen5")}"

  }

  storage_profile {
    storage_mb            = "${lookup(var.db, "storage_mb", 5120)}"
    backup_retention_days = "${lookup(var.db, "backup_retention_days", 7)}"
    geo_redundant_backup  = "${lookup(var.db, "geo_redundant_backup", "Disabled")}"
  }

  administrator_login          = "${lookup(var.db, "db_admin_name", "nuance_admin")}"
  administrator_login_password = "${var.postgres_admin_password}"
  version                      = "${lookup(var.db, "db_version", "11.4")}"
  ssl_enforcement              = "${lookup(var.db, "ssl_enforcement", "Enabled")}"

  tags = "${var.tags}"

  # https://www.terraform.io/docs/providers/azurerm/r/postgresql_server.html
}

resource "azurerm_postgresql_firewall_rule" "server" {
  name                = "${lookup(var.db, "firewall_rule_name", "myFirewallRule")}"
  resource_group_name = "${azurerm_resource_group.db.name}"
  server_name         = "${azurerm_postgresql_server.server.name}"
  start_ip_address    = "${lookup(var.db, "firewall_rule_start_ip", "10.0.0.0")}"
  end_ip_address      = "${lookup(var.db, "firewall_rule_end_ip", "10.255.255.255")}"

  # https://www.terraform.io/docs/providers/azurerm/r/postgresql_firewall_rule.html
}

variable "subnet_id" {
  type = "string"
}

resource "azurerm_postgresql_virtual_network_rule" "db" {
  name                = "postgresql-vnet-rule"
  resource_group_name = "${azurerm_resource_group.db.name}"
  server_name         = "${azurerm_postgresql_server.server.name}"
  subnet_id           = "${var.subnet_id}"
  # ignore_missing_vnet_service_endpoint (Optional) Should the Virtual Network Rule be created before the Subnet has the Virtual Network Service Endpoint enabled? Defaults to false
  ignore_missing_vnet_service_endpoint = true

  # https://www.terraform.io/docs/providers/azurerm/r/postgresql_virtual_network_rule.html
}

# https://docs.microsoft.com/en-us/azure/postgresql/concepts-pricing-tiers 
# Pricing https://azure.microsoft.com/en-us/pricing/details/postgresql/server/