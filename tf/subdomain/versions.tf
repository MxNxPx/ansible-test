terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azuredevops = {
      source = "terraform-providers/azuredevops"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    external = {
      source = "hashicorp/external"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
