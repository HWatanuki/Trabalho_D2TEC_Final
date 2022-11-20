locals {
  metadata = {
    project             = "hpcc_k8s_sa"
    product_name        = lower(var.product_name)
    business_unit       = "infra"
    environment         = "sandbox"
    market              = "us"
    product_group       = "solutionslab"
    resource_group_type = "shared"
    sre_team            = "solutionslab"
    subscription_type   = "dev"
  }

  names = module.metadata.names

  #----------------------------------------------------------------------------

  enforced_tags = {
    "admin"                      = var.admin_name
    "email"                      = lower(var.admin_email)
    "owner"                      = var.admin_name
    "owner_email"                = lower(var.admin_email)
    "last_modified_terraform"    = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }
  tags = merge(module.metadata.tags, local.enforced_tags, try(var.extra_tags, {}))

  #----------------------------------------------------------------------------

  storage = {
    name                     = lower("${var.admin_username}${local.metadata.product_name}")
    access_tier              = "Hot"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"

    quotas = {
	  "dalishare"  = var.storage_dali_gb
	  "dllsshare"  = 100,
	  "sashashare" = 50,
	  "datashare"  = var.storage_data_gb,
	  "lzshare"    = var.storage_lz_gb
	}
  }

  premium_storage = {
    name                     = lower("${var.admin_username}${local.metadata.product_name}premium")
    access_tier              = "Hot"
    account_kind             = "FileStorage"
    account_tier             = "Premium"
    account_replication_type = "LRS"

    quotas = { "dalishare" = var.storage_dali_gb >= 100 ? var.storage_dali_gb : 100 }
  }
}
