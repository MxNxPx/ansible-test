# -------------------------------------------------
# Subscription level information
# -------------------------------------------------

# Pull in nonprod subscription ID
data "azurerm_subscription" "nonprod" {
  subscription_id = var.non_prod_subscription_id
}

# Pull in prod subscription ID
data "azurerm_subscription" "prod" {
  subscription_id = var.prod_subscription_id
}