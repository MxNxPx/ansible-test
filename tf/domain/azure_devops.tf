# --------------------
# Azure DevOps Project
# --------------------
resource "azuredevops_project" "project" {
  name               = var.project_name
  description        = var.project_description
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    "testplans" = "disabled"
    "artifacts" = "disabled"
  }
  lifecycle {
    ignore_changes = [description, features]
  }
}

# ---------------------------------------------
# Authorize managed agent pool for this project
# ---------------------------------------------
data "azuredevops_agent_pool" "managed" {
  name = "Managed"
}

resource "azuredevops_agent_queue" "managed" {
  project_id    = azuredevops_project.project.id
  agent_pool_id = data.azuredevops_agent_pool.managed.id
}

resource "azuredevops_resource_authorization" "managed" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_agent_queue.managed.id
  type        = "queue"
  authorized  = true
}
# ---------------------------------
# Terraform Repository and Pipeline
# ---------------------------------
resource "azuredevops_git_repository" "infrastructure-repository" {
  project_id = azuredevops_project.project.id
  name       = "${local.domain_lc}-infrastructure"
  initialization {
    init_type = "Clean"
  }
}

# Create build definition. The YAML is created and committed by Megatron (outside TF)
resource "azuredevops_build_definition" "build_definition" {
  project_id = azuredevops_project.project.id
  name       = "${local.domain_lc}-build-definition"
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
  name        = "${local.domain_lc}-terraform-base"
  project_id  = azuredevops_project.project.id
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
    value = "${azuredevops_project.project.name}/${azuredevops_git_repository.infrastructure-repository.name}"
  }
  variable {
    name  = "TF_VAR_PROJECT_NAME"
    value = var.project_short_name
  }
  variable {
    name  = "TF_VAR_DATA_CLASSIFICATION"
    value = local.data_classification_lower
  }
  variable {
    name  = "TF_VAR_SHARED_RESOURCE_GROUP_NAME"
    value = var.non_prod_tf_state_resource_group_name
  }
  variable {
    name  = "TF_VAR_SHARED_NETWORKWATCHER_NAME"
    value = local.netwatch_name_nonprod
  }
  variable {
    name  = "TF_VAR_SHARED_NSGFLOW_LOG_SA_NAME"
    value = local.nsgflow_log_sa_name_nonprod
  }
  variable {
    name  = "TF_VAR_LOCATION"
    value = var.location
  }
  # Both nonprod and prod values are given here to avoid Azure DevOps template compilation issues
  variable {
    name  = "ARM_SERVICE_CONNECTION_NONPROD"
    value = azuredevops_serviceendpoint_azurerm.arm-sc-nonprod.service_endpoint_name
  }
  variable {
    name  = "ARM_SERVICE_CONNECTION_PROD"
    value = azuredevops_serviceendpoint_azurerm.arm-sc-prod.service_endpoint_name
  }
  variable {
    name  = "TF_STATE_RESOURCE_GROUP_NAME_NONPROD"
    value = var.non_prod_tf_state_resource_group_name
  }
  variable {
    name  = "TF_STATE_RESOURCE_GROUP_NAME_PROD"
    value = var.prod_tf_state_resource_group_name
  }
  variable {
    name  = "TF_STATE_STORAGE_ACCOUNT_NAME_NONPROD"
    value = var.non_prod_tf_state_storage_account_name
  }
  variable {
    name  = "TF_STATE_STORAGE_ACCOUNT_NAME_PROD"
    value = var.prod_tf_state_storage_account_name
  }
  variable {
    name  = "TF_STATE_CONTAINER_NAME"
    value = local.domain_lc
  }

  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}

resource "azuredevops_variable_group" "dev-terraform" {
  name        = "${local.domain_lc}-terraform-dev"
  project_id  = azuredevops_project.project.id
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
  name        = "${local.domain_lc}-terraform-tst"
  project_id  = azuredevops_project.project.id
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
  name        = "${local.domain_lc}-terraform-stg"
  project_id  = azuredevops_project.project.id
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
  name        = "${local.domain_lc}-terraform-prd"
  project_id  = azuredevops_project.project.id
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
    value = var.prod_tf_state_resource_group_name
  }
  variable {
    name  = "TF_VAR_SHARED_NETWORKWATCHER_NAME"
    value = local.netwatch_name_prod
  }
  variable {
    name  = "TF_VAR_SHARED_NSGFLOW_LOG_SA_NAME"
    value = local.nsgflow_log_sa_name_prod
  }

  # This is required to permit pipelines to run automatically after provisioning.
  # If this is false, the pipeline will pause and wait for approval before it's first run.
  allow_access = true
}

# ---------------------------------------------
# Service Connections required to use Terraform
# ---------------------------------------------
resource "azuredevops_serviceendpoint_azurerm" "arm-sc-nonprod" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "ARM-${local.domain_lc}-nonprod"
  credentials {
    serviceprincipalid  = azuread_application.app-the-project.application_id
    serviceprincipalkey = azuread_application_password.sp-project-terraform-runner-password.value
  }
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.non_prod_subscription_id
  azurerm_subscription_name = "8451"
}

resource "azuredevops_resource_authorization" "nonprod-auth" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_azurerm.arm-sc-nonprod.id
  authorized  = true
}

resource "azuredevops_serviceendpoint_azurerm" "arm-sc-prod" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "ARM-${local.domain_lc}-prod"
  credentials {
    serviceprincipalid  = azuread_application.app-the-project.application_id
    serviceprincipalkey = azuread_application_password.sp-project-terraform-runner-password.value
  }
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.prod_subscription_id
  azurerm_subscription_name = "8451"
}

resource "azuredevops_resource_authorization" "prod-auth" {
  project_id  = azuredevops_project.project.id
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

resource "azuredevops_group" "aad_admin" {
  origin_id  = azuread_group.admin.id
  depends_on = [azuread_group_member.agm-project-owner]
}

# -------------------------------
# Maintainer group and membership
# -------------------------------
resource "azuredevops_group" "maintainer" {
  scope        = azuredevops_project.project.id
  display_name = "Maintainers"
  description  = "Member of the contributor group, with additional repo privileges"
}

resource "azuredevops_group_membership" "maintainer" {
  group   = azuredevops_group.maintainer.id
  members = [azuredevops_group.aad_dvlpr.id]
  mode    = "add"
}

# --------------------------------
# Contributor group and membership
# --------------------------------
data "azuredevops_group" "contributor" {
  project_id = azuredevops_project.project.id
  name       = "Contributors"
}

resource "azuredevops_group_membership" "contributor" {
  group   = data.azuredevops_group.contributor.id
  members = [azuredevops_group.maintainer.id]
  mode    = "add"
}

# ---------------------------
# Project Team and membership
# ---------------------------
data "azuredevops_group" "project_team" {
  project_id = azuredevops_project.project.id
  name       = "${azuredevops_project.project.name} Team"
}

resource "azuredevops_group_membership" "project_team" {
  group   = data.azuredevops_group.project_team.id
  members = [azuredevops_group.aad_dvlpr.id]
  mode    = "add"
}

# ----------------------------------
# Administrator group and membership
# ----------------------------------
data "azuredevops_group" "administrator" {
  project_id = azuredevops_project.project.id
  name       = "Project Administrators"
}

resource "azuredevops_group_membership" "administrator" {
  group   = data.azuredevops_group.administrator.id
  members = [azuredevops_group.aad_admin.id]
  mode    = "add"
}

# ----------------------------------
# Readers group and membership
# ----------------------------------
data "azuredevops_group" "readers" {
  project_id = azuredevops_project.project.id
  name       = "Readers"
}

resource "azuredevops_group_membership" "readers" {
  group   = data.azuredevops_group.readers.id
  members = [var.azdo_user_group_azdo_id]
  mode    = "add"
}
