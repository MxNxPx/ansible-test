# --------------------
# Azure DevOps Project
# --------------------
data "azuredevops_project" "azure_devops_project" {
  name = var.parent_project_name
}

# ---------------------------------
# Terraform Repository and Pipeline
# ---------------------------------
resource "azuredevops_git_repository" "infrastructure-repository" {
  project_id = data.azuredevops_project.azure_devops_project.id
  name       = "${local.subdomain_lc}-infrastructure"
  initialization {
    init_type = "Clean"
  }
}

# Create build definition. The YAML is created and committed by Megatron (outside TF)
resource "azuredevops_build_definition" "build_definition" {
  project_id = data.azuredevops_project.azure_devops_project.id
  name       = "${local.subdomain_lc}-build-definition"
  path       = "\\"
  ci_trigger {
    use_yaml = true
  }
  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.infrastructure-repository.id
    branch_name = azuredevops_git_repository.infrastructure-repository.default_branch
    yml_path    = "azure-pipelines.yml"
  }
}

# -------------------------
# Terraform variable groups
# -------------------------
resource "azuredevops_variable_group" "base-terraform" {
  name        = "${local.subdomain_lc}-terraform-base"
  project_id  = data.azuredevops_project.azure_devops_project.id
  description = local.vg_description
  variable {
    name  = "TF_VAR_APPLICATION_NAME"
    value = var.project_name
  }
  variable {
    name  = "TF_VAR_BUSINESS_UNIT"
    value = var.business_unit
  }
  variable {
    name  = "TF_VAR_CONTACT"
    value = var.project_owner
  }
  variable {
    name  = "TF_VAR_AZDO_REPO"
    value = local.repo_name
  }
  variable {
    name  = "TF_VAR_PROJECT_NAME"
    value = var.project_short_name
  }
  variable {
    name  = "TF_VAR_PARENT_PROJECT_NAME"
    value = var.parent_project_short_name
  }
  variable {
    name  = "TF_VAR_DATA_CLASSIFICATION"
    value = local.data_classification_lower
  }
  variable {
    name  = "TF_VAR_SHARED_RESOURCE_GROUP_NAME"
    value = data.azurerm_resource_group.rg-nonprod-tfstate.name
  }
  variable {
    name  = "TF_VAR_SHARED_NETWORKWATCHER_NAME"
    value = data.azurerm_network_watcher.netwatch-nonprod.name
  }
  variable {
    name  = "TF_VAR_SHARED_NSGFLOW_LOG_SA_NAME"
    value = data.azurerm_storage_account.netwatch-nonprod.name
  }
  variable {
    name  = "TF_VAR_LOCATION"
    value = var.location
  }
  variable {
    name  = "ARM_SERVICE_CONNECTION_NONPROD"
    value = local.nonprod_sc_name
  }
  variable {
    name  = "ARM_SERVICE_CONNECTION_PROD"
    value = local.prod_sc_name
  }
  variable {
    name  = "TF_STATE_RESOURCE_GROUP_NAME_NONPROD"
    value = data.azurerm_storage_account.nonprod_state_sa.resource_group_name
  }
  variable {
    name  = "TF_STATE_RESOURCE_GROUP_NAME_PROD"
    value = data.azurerm_storage_account.prod_state_sa.resource_group_name
  }
  variable {
    name  = "TF_STATE_STORAGE_ACCOUNT_NAME_NONPROD"
    value = data.azurerm_storage_account.nonprod_state_sa.name
  }
  variable {
    name  = "TF_STATE_STORAGE_ACCOUNT_NAME_PROD"
    value = data.azurerm_storage_account.prod_state_sa.name
  }
  variable {
    name  = "TF_STATE_CONTAINER_NAME"
    value = "${local.domain_lc}-${local.subdomain_lc}"
  }
  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}

resource "azuredevops_variable_group" "dev-terraform" {
  name        = "${local.subdomain_lc}-terraform-dev"
  project_id  = data.azuredevops_project.azure_devops_project.id
  description = local.vg_description
  variable {
    name  = "TF_VAR_ENVIRONMENT"
    value = "dev"
  }
  variable {
    name  = "TF_VAR_RESOURCE_GROUP_NAME"
    value = azurerm_resource_group.rg-dev.name
  }

  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}

resource "azuredevops_variable_group" "tst-terraform" {
  name        = "${local.subdomain_lc}-terraform-tst"
  project_id  = data.azuredevops_project.azure_devops_project.id
  description = local.vg_description
  variable {
    name  = "TF_VAR_ENVIRONMENT"
    value = "tst"
  }
  variable {
    name  = "TF_VAR_RESOURCE_GROUP_NAME"
    value = azurerm_resource_group.rg-test.name
  }

  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}

resource "azuredevops_variable_group" "stg-terraform" {
  name        = "${local.subdomain_lc}-terraform-stg"
  project_id  = data.azuredevops_project.azure_devops_project.id
  description = local.vg_description
  variable {
    name  = "TF_VAR_ENVIRONMENT"
    value = "stg"
  }
  variable {
    name  = "TF_VAR_RESOURCE_GROUP_NAME"
    value = azurerm_resource_group.rg-stage.name
  }

  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}

resource "azuredevops_variable_group" "prd-terraform" {
  name        = "${local.subdomain_lc}-terraform-prd"
  project_id  = data.azuredevops_project.azure_devops_project.id
  description = local.vg_description
  variable {
    name  = "TF_VAR_ENVIRONMENT"
    value = "prd"
  }
  variable {
    name  = "TF_VAR_RESOURCE_GROUP_NAME"
    value = azurerm_resource_group.rg-prod.name
  }
  variable {
    name  = "TF_VAR_SHARED_RESOURCE_GROUP_NAME"
    value = data.azurerm_resource_group.rg-prod-tfstate.name
  }
  variable {
    name  = "TF_VAR_SHARED_NETWORKWATCHER_NAME"
    value = data.azurerm_network_watcher.netwatch-prod.name
  }
  variable {
    name  = "TF_VAR_SHARED_NSGFLOW_LOG_SA_NAME"
    value = data.azurerm_storage_account.netwatch-prod.name
  }

  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}
# ---------------------------------------------
# Service Connections required to use Terraform
# ---------------------------------------------
resource "azuredevops_serviceendpoint_azurerm" "arm-sc-nonprod" {
  project_id            = data.azuredevops_project.azure_devops_project.id
  service_endpoint_name = local.nonprod_sc_name
  credentials {
    serviceprincipalid  = azuread_application.app-the-project.application_id
    serviceprincipalkey = azuread_application_password.sp-project-terraform-runner-password.value
  }
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.non_prod_subscription_id
  azurerm_subscription_name = "8451"
}

resource "azuredevops_resource_authorization" "nonprod-auth" {
  project_id  = data.azuredevops_project.azure_devops_project.id
  resource_id = azuredevops_serviceendpoint_azurerm.arm-sc-nonprod.id
  authorized  = true
}

resource "azuredevops_serviceendpoint_azurerm" "arm-sc-prod" {
  project_id            = data.azuredevops_project.azure_devops_project.id
  service_endpoint_name = local.prod_sc_name
  credentials {
    serviceprincipalid  = azuread_application.app-the-project.application_id
    serviceprincipalkey = azuread_application_password.sp-project-terraform-runner-password.value
  }
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.prod_subscription_id
  azurerm_subscription_name = "8451"
}

resource "azuredevops_resource_authorization" "prod-auth" {
  project_id  = data.azuredevops_project.azure_devops_project.id
  resource_id = azuredevops_serviceendpoint_azurerm.arm-sc-prod.id
  authorized  = true
}
# -------------------------------------------------
# External AAD groups required for group membership
# -------------------------------------------------

resource "azuredevops_group" "aad_dvlpr" {
  origin_id  = azuread_group.dvlpr.id
  depends_on = [azuread_group_member.admin-is-developer]
}
# This is not actually used yet, but will be used when the team supports adding a team admin other than the creator
resource "azuredevops_group" "aad_admin" {
  origin_id  = azuread_group.admin.id
  depends_on = [azuread_group_member.agm-project-owner]
}

# ---------------------------------
# Team for SubDomain and membership
# ---------------------------------
resource "null_resource" "azdo_team" {
  provisioner "local-exec" {
    command = "az devops team create --name=\"${self.triggers.project_name} Team\" --description=\"Development Team for the project\" --organization=https://dev.azure.com/8451 --project=\"${self.triggers.parent_project_name}\""
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az devops team delete --id=\"${self.triggers.project_name} Team\" --organization=https://dev.azure.com/8451 --project=\"${self.triggers.parent_project_name}\" --yes"
  }
  triggers = {
    project_name        = var.project_name
    parent_project_name = var.parent_project_name
  }
}

data "azuredevops_group" "project_team" {
  project_id = data.azuredevops_project.azure_devops_project.id
  name       = "${var.project_name} Team"
  depends_on = [null_resource.azdo_team]
}

resource "azuredevops_group_membership" "project_team" {
  group   = data.azuredevops_group.project_team.id
  members = [azuredevops_group.aad_dvlpr.id]
  mode    = "add"
}

# -------------------------------
# Maintainer group and membership
# -------------------------------
data "azuredevops_group" "maintainers" {
  project_id = data.azuredevops_project.azure_devops_project.id
  name       = "Maintainers"
}

resource "azuredevops_group_membership" "maintainer" {
  group   = data.azuredevops_group.maintainers.id
  members = [azuredevops_group.aad_dvlpr.id]
  mode    = "add"
}
