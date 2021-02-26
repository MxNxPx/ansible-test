# We will supply the configuration in the Terraform init (via a dictionary)
terraform {
  backend "azurerm" {
    resource_group_name = "rg-poc-shared-nonprod"
    storage_account_name = "sa8451tfpocnprd"
    container_name = "poc-cloudfypoc"
    key = "cdomtest.tfstate"
  }
}
