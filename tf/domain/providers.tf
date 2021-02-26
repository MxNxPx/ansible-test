# Configure the Azure Provider
provider "azurerm" {
  version = "=2.19.0"
  features {}
  subscription_id = var.non_prod_subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

provider "azurerm" {
  # Alias this to distinguish it from it's non-prod variant above
  alias   = "prod"
  version = "=2.19.0"
  features {}
  subscription_id = var.prod_subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Configure the Microsoft Azure Active Directory Provider
provider "azuread" {
  version         = "=0.11.0"
  subscription_id = var.non_prod_subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.ad_client_id
  client_secret   = var.ad_client_secret
}

provider "azuredevops" {
  version               = ">= 0.0.1"
  org_service_url       = var.azdo_organization_url
  personal_access_token = var.azdo_pat
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}