# Pull in information on project owner
data "azuread_user" "adu-project-owner" {
  user_principal_name = var.project_owner
}

# Pull in information on Azure DevOps User group
data "azuread_group" "azdo-user" {
  name = "gAZAzureDevOpsUser"
}

# Pull in information on data classification terraform runners group
data "azuread_group" "data-classification-terraform-runners" {
  name = "gAZ${local.data_classification_title}TerraformRunners"
}

# AAD Groups
resource "azuread_group" "suprt" {
  name   = "gAZ${local.domain_ucfirst}Suprt"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "dvlpr" {
  name   = "gAZ${local.domain_ucfirst}Dvlpr"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "admin" {
  name   = "gAZ${local.domain_ucfirst}Admin"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "data-read" {
  name   = "gAZ${local.domain_ucfirst}DataRead"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "data-write" {
  name   = "gAZ${local.domain_ucfirst}DataWrite"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "terraform_runners" {
  name        = "gAZ${local.domain_ucfirst}TerraformRunners"
  description = "${local.domain_ucfirst} Domain and SubDomain Terraform service principals"
}

# Make developers a member of the support group
resource azuread_group_member "developer-is-support" {
  group_object_id  = azuread_group.suprt.id
  member_object_id = azuread_group.dvlpr.id
}

# Make project owner an admin by default
resource azuread_group_member "agm-project-owner" {
  group_object_id  = azuread_group.admin.id
  member_object_id = data.azuread_user.adu-project-owner.id
}

# Add terraform runner to terraform runners group
resource "azuread_group_member" "terraform-runner-group-assignment" {
  group_object_id  = azuread_group.terraform_runners.id
  member_object_id = azuread_service_principal.sp-project-terraform-runner.object_id
}

# Add terraform runners group to data classification terraform runners
resource azuread_group_member "terraform-runners-is-data-classification-runner" {
  group_object_id  = data.azuread_group.data-classification-terraform-runners.id
  member_object_id = azuread_group.terraform_runners.id
}

# Make admin group a member of dvlpr group
resource "azuread_group_member" "admin-is-developer" {
  group_object_id  = azuread_group.dvlpr.id
  member_object_id = azuread_group.admin.object_id
}

# Add developer group to AzDO user
resource "azuread_group_member" "developer-is-azdo-user" {
  group_object_id  = data.azuread_group.azdo-user.id
  member_object_id = azuread_group.dvlpr.id
}