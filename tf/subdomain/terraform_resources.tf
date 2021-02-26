# Create the terraform runner service principal for the project, and assign it to the admin group
resource "azuread_application" "app-the-project" {
  name                       = "sp${local.domain_ucfirst}${local.subdomain_ucfirst}Terraform"
  homepage                   = "https://${local.domain_ucfirst}${local.subdomain_ucfirst}Terraform-home"
  identifier_uris            = ["https://${local.domain_ucfirst}${local.subdomain_ucfirst}Terraform-uri"]
  reply_urls                 = ["https://${local.domain_ucfirst}${local.subdomain_ucfirst}Terraform-replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "sp-project-terraform-runner" {
  application_id               = azuread_application.app-the-project.application_id
  app_role_assignment_required = false

  tags = ["ApplicationName='${var.project_name}'",
    "BusinessUnit='${var.business_unit}'",
    "Provisioner='${var.provisioner}'",
    "Contact='${var.project_owner}'"
  ]

}
resource "random_password" "terraform-runner-random-pass" {
  length = 32
}
resource "azuread_application_password" "sp-project-terraform-runner-password" {
  application_object_id = azuread_application.app-the-project.object_id
  value                 = random_password.terraform-runner-random-pass.result
  end_date_relative     = "17520h"
}

# Create non-prod state container
data "azurerm_resource_group" "rg-nonprod-tfstate" {
  name = var.non_prod_tf_state_resource_group_name
}

data "azurerm_storage_account" "nonprod_state_sa" {
  name                = var.non_prod_tf_state_storage_account_name
  resource_group_name = data.azurerm_resource_group.rg-nonprod-tfstate.name
}

resource "azurerm_storage_container" "nonprod_state_container" {
  name                 = "${local.domain_lc}-${local.subdomain_lc}"
  storage_account_name = data.azurerm_storage_account.nonprod_state_sa.name
}

resource "azurerm_role_assignment" "terraform_runner_read_nonprod_state" {
  principal_id         = azuread_service_principal.sp-project-terraform-runner.object_id
  scope                = azurerm_storage_container.nonprod_state_container.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
}

# Create prod state container
data "azurerm_resource_group" "rg-prod-tfstate" {
  provider = azurerm.prod
  name     = var.prod_tf_state_resource_group_name
}

data "azurerm_storage_account" "prod_state_sa" {
  provider            = azurerm.prod
  name                = var.prod_tf_state_storage_account_name
  resource_group_name = data.azurerm_resource_group.rg-prod-tfstate.name
}

resource "azurerm_storage_container" "prod_state_container" {
  provider             = azurerm.prod
  name                 = "${local.domain_lc}-${local.subdomain_lc}"
  storage_account_name = data.azurerm_storage_account.prod_state_sa.name
}

resource "azurerm_role_assignment" "terraform_runner_read_prod_state" {
  provider             = azurerm.prod
  principal_id         = azuread_service_principal.sp-project-terraform-runner.object_id
  scope                = azurerm_storage_container.prod_state_container.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
}
