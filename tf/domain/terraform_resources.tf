# Create the terraform runner service principal for the project, and assign it to the admin group
resource "azuread_application" "app-the-project" {
  name                       = "sp${local.domain_ucfirst}Terraform"
  homepage                   = "https://${local.domain_ucfirst}Terraform-home"
  identifier_uris            = ["https://${local.domain_ucfirst}Terraform-uri"]
  reply_urls                 = ["https://${local.domain_ucfirst}Terraform-replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "sp-project-terraform-runner" {
  application_id               = azuread_application.app-the-project.application_id
  app_role_assignment_required = false

  tags = ["ApplicationName='${var.application_name}'",
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

# Create non-prod terraform state resource group, storage account, and container
resource "azurerm_resource_group" "rg-nonprod-tfstate" {
  location = var.location
  name     = var.non_prod_tf_state_resource_group_name
  tags = {
    ApplicationName = var.application_name
    BusinessUnit    = var.business_unit
    Provisioner     = var.provisioner
    Contact         = var.project_owner
    Environment     = "nonprod"
  }
}

resource "azurerm_storage_account" "nonprod_state_sa" {
  name                      = var.non_prod_tf_state_storage_account_name
  resource_group_name       = azurerm_resource_group.rg-nonprod-tfstate.name
  location                  = azurerm_resource_group.rg-nonprod-tfstate.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  is_hns_enabled            = false
  allow_blob_public_access  = false

  network_rules {
    default_action = "Allow"
  }

  # Disable the TF-prevent_destroy lifecycle until Hashicorp allows this to be conditionally set
  # ref: https://github.com/hashicorp/terraform/issues/22544
  lifecycle {
    prevent_destroy = false
  }

  tags = azurerm_resource_group.rg-nonprod-tfstate.tags

}

resource "azurerm_storage_container" "nonprod_state_container" {
  name                 = local.domain_lc
  storage_account_name = azurerm_storage_account.nonprod_state_sa.name
}

resource "azurerm_role_assignment" "terraform_runner_read_nonprod_state_container" {
  principal_id         = azuread_service_principal.sp-project-terraform-runner.object_id
  scope                = azurerm_storage_container.nonprod_state_container.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "terraform_runner_read_nonprod_storage_account" {
  principal_id         = azuread_group.terraform_runners.id
  scope                = azurerm_storage_account.nonprod_state_sa.id
  role_definition_name = "Reader and Data Access"
}

resource "azurerm_role_assignment" "terraform_runner_register_resource_providers_nonprod" {
  principal_id         = azuread_group.terraform_runners.id
  scope                = data.azurerm_subscription.nonprod.id
  role_definition_name = "role-tfrunner-subscription"
}
# Create prod terraform state resource group, storage account, and container
resource "azurerm_resource_group" "rg-prod-tfstate" {
  provider = azurerm.prod
  location = var.location
  name     = var.prod_tf_state_resource_group_name
  tags = {
    ApplicationName = var.application_name
    BusinessUnit    = var.business_unit
    Provisioner     = var.provisioner
    Contact         = var.project_owner
    Environment     = "prod"
  }
}

resource "azurerm_storage_account" "prod_state_sa" {
  provider                  = azurerm.prod
  name                      = var.prod_tf_state_storage_account_name
  resource_group_name       = azurerm_resource_group.rg-prod-tfstate.name
  location                  = azurerm_resource_group.rg-prod-tfstate.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  is_hns_enabled            = false
  allow_blob_public_access  = false

  network_rules {
    default_action = "Allow"
  }

  # Disable the TF-prevent_destroy lifecycle until Hashicorp allows this to be conditionally set
  # ref: https://github.com/hashicorp/terraform/issues/22544
  lifecycle {
    prevent_destroy = false
  }

  tags = azurerm_resource_group.rg-prod-tfstate.tags
}

resource "azurerm_storage_container" "prod_state_container" {
  provider             = azurerm.prod
  name                 = local.domain_lc
  storage_account_name = azurerm_storage_account.prod_state_sa.name
}

resource "azurerm_role_assignment" "terraform_runner_read_prod_state" {
  provider             = azurerm.prod
  principal_id         = azuread_service_principal.sp-project-terraform-runner.object_id
  scope                = azurerm_storage_container.prod_state_container.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "terraform_runner_read_prod_storage_account" {
  provider             = azurerm.prod
  principal_id         = azuread_group.terraform_runners.id
  scope                = azurerm_storage_account.prod_state_sa.id
  role_definition_name = "Reader and Data Access"
}

resource "azurerm_role_assignment" "terraform_runner_register_resource_providers_prod" {
  provider             = azurerm.prod
  principal_id         = azuread_group.terraform_runners.id
  scope                = data.azurerm_subscription.prod.id
  role_definition_name = "role-tfrunner-subscription"
}