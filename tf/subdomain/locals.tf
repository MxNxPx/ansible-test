locals {
  # setup local versions of these vars to enforce convention
  domain_lc                 = lower(var.parent_project_short_name)
  subdomain_lc              = lower(var.project_short_name)
  domain_ucfirst            = title(lower(var.parent_project_short_name))
  subdomain_ucfirst         = title(lower(var.project_short_name))
  data_classification_title = join("", [for part in split("-", trimsuffix(trimprefix(var.non_prod_management_group_name, "mg-8451-"), "-nonprod")) : title(part)])
  data_classification_lower = lower(local.data_classification_title)
  is_legacy                 = var.non_prod_subscription_id == "3aa4497f-2534-4cba-8ea6-36bfaf43c6d2" ? true : false
  vg_description            = "DO NOT MODIFY THIS VARIABLE GROUP! This variable group is maintained by Megatron, and values within it can be changed by Megatron. Any changes made here will be reversed by Megatron."

  # These are defined here to avoid a dependency on service connections and repos in the variable group (older projects have lost state of SCs due to provider issues)
  nonprod_sc_name = "ARM-${local.domain_lc}-${local.subdomain_lc}-nonprod"
  prod_sc_name    = "ARM-${local.domain_lc}-${local.subdomain_lc}-prod"
  repo_name       = "${data.azuredevops_project.azure_devops_project.name}/${local.subdomain_lc}-infrastructure"
}