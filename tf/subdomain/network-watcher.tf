data "azurerm_network_watcher" "netwatch-nonprod" {
  name                = local.is_legacy ? "netwatch-nonprod-eastus2" : "netwatch-${local.domain_lc}-nonprod"
  resource_group_name = local.is_legacy ? "rg-netwatch-nonprod" : data.azurerm_resource_group.rg-nonprod-tfstate.name
}

data "azurerm_network_watcher" "netwatch-prod" {
  name                = local.is_legacy ? "netwatch-prod-eastus2" : "netwatch-${local.domain_lc}-prod"
  resource_group_name = local.is_legacy ? "rg-netwatch-prod" : data.azurerm_resource_group.rg-prod-tfstate.name

  provider = azurerm.prod
}

data "azurerm_storage_account" "netwatch-nonprod" {
  name                = local.is_legacy ? "sa8451netlegacynprd" : "sa8451net${local.domain_lc}nprd"
  resource_group_name = data.azurerm_resource_group.rg-nonprod-tfstate.name
}
data "azurerm_storage_account" "netwatch-prod" {
  name                = local.is_legacy ? "sa8451netlegacyprod" : "sa8451net${local.domain_lc}prod"
  resource_group_name = data.azurerm_resource_group.rg-prod-tfstate.name

  provider = azurerm.prod
}