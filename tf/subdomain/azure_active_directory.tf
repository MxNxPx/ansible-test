# Pull in information on project owner
data "azuread_user" "adu-project-owner" {
  user_principal_name = var.project_owner
}

# Pull in information on terraform runner group
data "azuread_group" "terraform-runners" {
  name = "gAZ${local.domain_ucfirst}TerraformRunners"
}

# Pull in information on Azure DevOps User group
data "azuread_group" "azdo-user" {
  name = "gAZAzureDevOpsUser"
}

# AAD Groups
resource "azuread_group" "suprt" {
  name   = "gAZ${local.domain_ucfirst}${local.subdomain_ucfirst}Suprt"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "dvlpr" {
  name   = "gAZ${local.domain_ucfirst}${local.subdomain_ucfirst}Dvlpr"
  owners = [data.azuread_user.adu-project-owner.id]
}

resource "azuread_group" "admin" {
  name   = "gAZ${local.domain_ucfirst}${local.subdomain_ucfirst}Admin"
  owners = [data.azuread_user.adu-project-owner.id]
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
  group_object_id  = data.azuread_group.terraform-runners.object_id
  member_object_id = azuread_service_principal.sp-project-terraform-runner.object_id
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