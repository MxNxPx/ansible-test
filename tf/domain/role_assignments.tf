# -----------------------------------------------------------
# Dev
resource "azurerm_role_assignment" "dev_suprt" {
  scope                = azurerm_resource_group.rg-dev.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.suprt.id
}

resource "azurerm_role_assignment" "dev_dvlpr" {
  scope                = azurerm_resource_group.rg-dev.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.dvlpr.id
}

resource "azurerm_role_assignment" "dev_terraform" {
  scope                = azurerm_resource_group.rg-dev.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp-project-terraform-runner.id
}

resource "azurerm_role_assignment" "dev_data_read" {
  scope                = azurerm_resource_group.rg-dev.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.data-read.id
}

resource "azurerm_role_assignment" "dev_data_write" {
  scope                = azurerm_resource_group.rg-dev.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.data-write.id
}

# -----------------------------------------------------------
# Test
resource "azurerm_role_assignment" "test_suprt" {
  scope                = azurerm_resource_group.rg-test.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.suprt.id
}

resource "azurerm_role_assignment" "test_dvlpr" {
  scope                = azurerm_resource_group.rg-test.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.dvlpr.id
}

resource "azurerm_role_assignment" "tst_terraform" {
  scope                = azurerm_resource_group.rg-test.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp-project-terraform-runner.id
}

resource "azurerm_role_assignment" "test_data_read" {
  scope                = azurerm_resource_group.rg-test.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.data-read.id
}

resource "azurerm_role_assignment" "test_data_write" {
  scope                = azurerm_resource_group.rg-test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.data-write.id
}

# -----------------------------------------------------------
# Stage
resource "azurerm_role_assignment" "stage_suprt" {
  scope                = azurerm_resource_group.rg-stage.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.suprt.id
}

resource "azurerm_role_assignment" "stage_dvlpr" {
  scope                = azurerm_resource_group.rg-stage.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.dvlpr.id
}

resource "azurerm_role_assignment" "stage_terraform" {
  scope                = azurerm_resource_group.rg-stage.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp-project-terraform-runner.id
}

resource "azurerm_role_assignment" "stage_data_read" {
  scope                = azurerm_resource_group.rg-stage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.data-read.id
}

resource "azurerm_role_assignment" "stage_data_write" {
  scope                = azurerm_resource_group.rg-stage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.data-write.id
}

# -----------------------------------------------------------
# Prod
resource "azurerm_role_assignment" "prod_suprt" {
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.suprt.id
}

resource "azurerm_role_assignment" "prod_dvlpr" {
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.dvlpr.id
}

resource "azurerm_role_assignment" "prod_terraform" {
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp-project-terraform-runner.id
}

resource "azurerm_role_assignment" "prod_data_read" {
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.data-read.id
}

resource "azurerm_role_assignment" "prod_data_write" {
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.data-write.id
}

# -----------------------------------------------------------
# Support Request Contributor at subscription level
# TODO: Remove counts once domains have migrated to new subscriptions
data "azuread_group" "unrestricted_support" {
  count = local.is_legacy ? 1 : 0 # Only use this if it is a legacy domain
  name  = "gAZUnrestrictedSupport"
}

# If domain is in legacy subs
resource "azuread_group_member" "suprt_supportreq" {
  count            = local.is_legacy ? 1 : 0
  group_object_id  = data.azuread_group.unrestricted_support[0].id
  member_object_id = azuread_group.suprt.id
}

# Else
resource "azurerm_role_assignment" "nonprod_suprt_supportreq" {
  count                = local.is_legacy ? 0 : 1
  scope                = data.azurerm_subscription.nonprod.id
  role_definition_name = "Support Request Contributor"
  principal_id         = azuread_group.suprt.id
}

resource "azurerm_role_assignment" "prod_suprt_supportreq" {
  count                = local.is_legacy ? 0 : 1
  scope                = data.azurerm_subscription.prod.id
  role_definition_name = "Support Request Contributor"
  principal_id         = azuread_group.suprt.id
}
