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

# -----------------------------------------------------------
# Prod
resource "azurerm_role_assignment" "prod_suprt" {
  provider             = azurerm.prod
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.suprt.id
}

resource "azurerm_role_assignment" "prod_dvlpr" {
  provider             = azurerm.prod
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.dvlpr.id
}

resource "azurerm_role_assignment" "prod_terraform" {
  provider             = azurerm.prod
  scope                = azurerm_resource_group.rg-prod.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp-project-terraform-runner.id
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
