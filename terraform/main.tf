terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
    version = "~>2.0"
    features {}
}

# RESOURCE GROUP
resource "azurerm_resource_group" "k8s-group" {
    name = var.resource_group_name
    location = var.location
}

# CONTAINER REGISTRY
resource "azurerm_container_registry" "acr" {
  name = var.acr_name
  resource_group_name = azurerm_resource_group.k8s-group.name
  location = azurerm_resource_group.k8s-group.location
  sku = "Basic"
}

# K8s CLUSTER
resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name = var.k8s_cluster_name
  location = azurerm_resource_group.k8s-group.location
  resource_group_name = azurerm_resource_group.k8s-group.name
  dns_prefix = var.k8s_dns_prefix

  default_node_pool {
    name = "default"
    node_count = 2
    vm_size = var.k8s_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "k8s_to_acr" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.k8s_cluster.kubelet_identity[0].object_id
}

# DATABASE
resource "azurerm_postgresql_server" "db_server" {
  name = var.db_server_name
  location = azurerm_resource_group.k8s-group.location
  resource_group_name = azurerm_resource_group.k8s-group.name

  sku_name = "B_Gen5_2"

  storage_mb = 5120
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled = true

  administrator_login = var.db_user
  administrator_login_password = var.db_password
  version = "9.5"
  ssl_enforcement_enabled = true
}

resource "azurerm_postgresql_database" "db_name" {
  name = var.db_name
  resource_group_name = azurerm_resource_group.k8s-group.name
  server_name = azurerm_postgresql_server.db_server.name
  charset = "UTF8"
  collation = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "db_firewall" {
  name = "home"
  resource_group_name = azurerm_resource_group.k8s-group.name
  server_name = azurerm_postgresql_server.db_server.name
  start_ip_address  = "0.0.0.0"
  end_ip_address = "255.255.255.255"
}

# REDIS
resource "azurerm_redis_cache" "broker" {
  name = var.broker_name
  location = azurerm_resource_group.k8s-group.location
  resource_group_name = azurerm_resource_group.k8s-group.name
  capacity  = 2
  family = "C"
  sku_name = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

# Files
resource "azurerm_storage_account" "files_account" {
  name = var.files_account_name
  resource_group_name = azurerm_resource_group.k8s-group.name
  location = azurerm_resource_group.k8s-group.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "files" {
  name = var.files_name
  storage_account_name = azurerm_storage_account.files_account.name
}



