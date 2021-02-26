resource "azurerm_resource_group" "rg-dev" {
  location = var.location
  name     = "rg-${local.domain_lc}-dev"
  tags = {
    ApplicationName = var.application_name
    BusinessUnit    = var.business_unit
    Provisioner     = var.provisioner
    Contact         = var.project_owner
    Environment     = "dev"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_resource_group" "rg-test" {
  location = var.location
  name     = "rg-${local.domain_lc}-tst"
  tags = {
    ApplicationName = var.application_name
    BusinessUnit    = var.business_unit
    Provisioner     = var.provisioner
    Contact         = var.project_owner
    Environment     = "tst"
  }
}

resource "azurerm_resource_group" "rg-stage" {
  location = var.location
  name     = "rg-${local.domain_lc}-stg"
  tags = {
    ApplicationName = var.application_name
    BusinessUnit    = var.business_unit
    Provisioner     = var.provisioner
    Contact         = var.project_owner
    Environment     = "stg"
  }
}

resource "azurerm_resource_group" "rg-prod" {
  provider = azurerm.prod
  location = var.location
  name     = "rg-${local.domain_lc}-prd"
  tags = {
    ApplicationName = var.application_name
    BusinessUnit    = var.business_unit
    Provisioner     = var.provisioner
    Contact         = var.project_owner
    Environment     = "prd"
  }
}