locals {
  # setup local versions of these vars to enforce convention
  domain_lc      = lower(var.project_short_name)
  domain_ucfirst = title(lower(var.project_short_name))
  # Example mg name: mg-8451-restricted-phi, mg-8451-unrestricted-nonprod
  data_classification_title = join("", [for part in split("-", trimsuffix(trimprefix(var.non_prod_management_group_name, "mg-8451-"), "-nonprod")) : title(part)])
  data_classification_lower = lower(local.data_classification_title)
  is_legacy                 = var.non_prod_subscription_id == "3aa4497f-2534-4cba-8ea6-36bfaf43c6d2" ? true : false
  vg_description            = "DO NOT MODIFY THIS VARIABLE GROUP! This variable group is maintained by Megatron, and values within it can be changed by Megatron. Any changes made here will be reversed by Megatron."

  # These are defined here to avoid dependencies on network watcher resources in the variable groups, as older domains do not create their own network watcher
  nsgflow_log_sa_name_nonprod = "sa8451net${local.domain_lc}nprd"
  nsgflow_log_sa_name_prod    = "sa8451net${local.domain_lc}prod"
  netwatch_name_nonprod       = local.is_legacy ? "netwatch-nonprod-eastus2" : "netwatch-${local.domain_lc}-nonprod"
  netwatch_name_prod          = local.is_legacy ? "netwatch-prod-eastus2" : "netwatch-${local.domain_lc}-prod"
}