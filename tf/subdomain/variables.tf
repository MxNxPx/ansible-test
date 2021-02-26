variable "tenant_id" {
  description = "The Azure tenant for 84.51º"
  type        = string
}

variable "non_prod_subscription_id" {
  description = "The Azure subscription for non-production resources for 84.51º"
  type        = string
}

variable "client_id" {
  description = "The Azure service principal's client id for non-production"
  type        = string
}

variable "client_secret" {
  description = "The Azure service principal's client secret for non-production"
  type        = string
}

variable "ad_client_id" {
  description = "The Azure service principal's client id for non-production"
  type        = string
}

variable "ad_client_secret" {
  description = "The Azure service principal's client secret for non-production"
  type        = string
}

variable "prod_subscription_id" {
  description = "The Azure subscription for production resources for 84.51º"
  type        = string
}

variable "provisioner" {
  description = "Leader of the Decepticons - all will bow before Megatron!"
  type        = string
  default     = "Megatron"
}

variable "project_name" {
  description = "String defining the Azure DevOps project name"
  type        = string
}

variable "project_description" {
  description = "String describing the Azure DevOps project"
  type        = string
}

variable "project_owner" {
  description = "Email address of the Project owner"
  type        = string
}

variable location {
  description = "Azure region for resources created in this Terraform"
  type        = string
  default     = "eastus2"
}

variable "business_unit" {
  description = "Business unit for tagging purposes"
  type        = string
}

variable "azdo_pat" {
  type = string
}

variable "non_prod_tf_state_resource_group_name" {
  type        = string
  description = "The name of the resource group in which the non-prod Terraform state storage account resides"
}

variable "non_prod_tf_state_storage_account_name" {
  type        = string
  description = "The name of the storage account to generate to hold non-prod Terraform state"
}

variable "prod_tf_state_resource_group_name" {
  type        = string
  description = "The name of the resource group in which the prod Terraform state storage account resides"
}

variable "prod_tf_state_storage_account_name" {
  type        = string
  description = "The name of the storage account to generate to hold production Terraform state"
}

variable "project_short_name" {
  type        = string
  description = "Short name of project ex: acds"
}

variable "parent_project_short_name" {
  type        = string
  description = "Short name of domain that owns this subdomain ex: PoS"
}

variable "parent_project_name" {
  type        = string
  description = "Long name of domain that owns this subdomain ex: Point of Sale. Used as Azure DevOps project name."
}

variable "azdo_organization_url" {
  type        = string
  default     = "https://dev.azure.com/8451"
  description = "Organization URL for Azure DevOps. Controls which Organization the AzDO resources are created in."
}

# These are not used in a subdomain yet, but adding here to prevent a terraform error when Megatron provides a value for them
variable "non_prod_management_group_name" {
  type        = string
  default     = "mg-8451-unrestricted-nonprod"
  description = "Name of the non prod management group"
}

variable "prod_management_group_name" {
  type        = string
  default     = "mg-8451-unrestricted-prod"
  description = "Name of the prod management group"
}