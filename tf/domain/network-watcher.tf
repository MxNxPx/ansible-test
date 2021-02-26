# Subscription network watcher

# Non-Production network watcher
resource "azurerm_network_watcher" "netwatch-nonprod" {
  name                = local.netwatch_name_nonprod
  resource_group_name = azurerm_resource_group.rg-nonprod-tfstate.name
  location            = var.location

  tags = azurerm_resource_group.rg-nonprod-tfstate.tags
}

resource "azurerm_storage_account" "netwatch-nonprod" {
  name                      = local.nsgflow_log_sa_name_nonprod
  resource_group_name       = azurerm_resource_group.rg-nonprod-tfstate.name
  location                  = azurerm_resource_group.rg-nonprod-tfstate.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  is_hns_enabled            = false
  allow_blob_public_access  = false

  tags = azurerm_resource_group.rg-nonprod-tfstate.tags

}

# Production network watcher
resource "azurerm_network_watcher" "netwatch-prod" {
  name                = local.netwatch_name_prod
  resource_group_name = azurerm_resource_group.rg-prod-tfstate.name
  location            = var.location

  tags = azurerm_resource_group.rg-prod-tfstate.tags

  provider = azurerm.prod
}

resource "azurerm_storage_account" "netwatch-prod" {
  name                      = local.nsgflow_log_sa_name_prod
  resource_group_name       = azurerm_resource_group.rg-prod-tfstate.name
  location                  = azurerm_resource_group.rg-prod-tfstate.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  is_hns_enabled            = false
  allow_blob_public_access  = false

  tags = azurerm_resource_group.rg-prod-tfstate.tags

  provider = azurerm.prod

}

# ---------------------------
# Resource locks
# ---------------------------
resource "azurerm_management_lock" "netwatch_nonprod_lock" {
  name       = "lock-${azurerm_network_watcher.netwatch-nonprod.name}"
  scope      = azurerm_network_watcher.netwatch-nonprod.id
  lock_level = "CanNotDelete"
  notes      = "This resource cannot be deleted but can be modified by admins"
}

resource "azurerm_management_lock" "netwatch_prod_lock" {
  name       = "lock-${azurerm_network_watcher.netwatch-prod.name}"
  scope      = azurerm_network_watcher.netwatch-prod.id
  lock_level = "CanNotDelete"
  notes      = "This resource cannot be deleted but can be modified by admins"
}

resource "azurerm_management_lock" "netwatch_sa_nonprod_lock" {
  name       = "lock-${azurerm_storage_account.netwatch-nonprod.name}"
  scope      = azurerm_storage_account.netwatch-nonprod.id
  lock_level = "CanNotDelete"
  notes      = "This resource cannot be deleted but can be modified by admins"
}

resource "azurerm_management_lock" "netwatch_sa_prod_lock" {
  name       = "lock-${azurerm_storage_account.netwatch-prod.name}"
  scope      = azurerm_storage_account.netwatch-prod.id
  lock_level = "CanNotDelete"
  notes      = "This resource cannot be deleted but can be modified by admins"
}