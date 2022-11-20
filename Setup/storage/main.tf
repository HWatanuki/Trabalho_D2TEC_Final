resource "random_string" "random" {
  length  = 43
  upper   = false
  numeric = false
  special = false
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  naming_rules = module.naming.yaml

  market              = local.metadata.market
  location            = lower(var.azure_region)
  sre_team            = local.metadata.sre_team
  environment         = local.metadata.environment
  product_name        = local.metadata.product_name
  business_unit       = local.metadata.business_unit
  product_group       = local.metadata.product_group
  subscription_type   = local.metadata.subscription_type
  resource_group_type = local.metadata.resource_group_type
  subscription_id     = data.azurerm_subscription.current.id
  project             = local.metadata.project
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  unique_name = false
  location    = lower(var.azure_region)
  names       = local.names
  tags        = local.tags
}

resource "azurerm_storage_account" "standard_storage_account" {

  name                             = local.storage.name
  resource_group_name              = module.resource_group.name
  location                         = module.resource_group.location
  access_tier                      = local.storage.access_tier
  account_kind                     = local.storage.account_kind
  account_tier                     = local.storage.account_tier
  account_replication_type         = local.storage.account_replication_type
  shared_access_key_enabled        = true
  min_tls_version                  = "TLS1_2"
  large_file_share_enabled         = true
  tags                             = local.tags
}

resource "azurerm_storage_share" "standard_storage_shares" {
  for_each = local.storage.quotas

  name                 = each.key
  storage_account_name = azurerm_storage_account.standard_storage_account.name
  quota                = each.value

  acl {
    id = random_string.random.result

    access_policy {
      permissions = "rwdl"
    }
  }
}

resource "azurerm_storage_account" "premium_storage_account" {
  count = var.enable_premium_storage ? 1 : 0

  name                             = local.premium_storage.name
  resource_group_name              = module.resource_group.name
  location                         = module.resource_group.location
  access_tier                      = local.premium_storage.access_tier
  account_kind                     = local.premium_storage.account_kind
  account_tier                     = local.premium_storage.account_tier
  account_replication_type         = local.premium_storage.account_replication_type
  shared_access_key_enabled        = true
  min_tls_version                  = "TLS1_2"
  tags                             = local.tags
}

resource "azurerm_storage_share" "premium_storage_shares" {
  for_each = var.enable_premium_storage ? local.premium_storage.quotas : {}

  name                 = each.key
  storage_account_name = azurerm_storage_account.premium_storage_account[0].name
  quota                = each.value

  acl {
    id = random_string.random.result

    access_policy {
      permissions = "rwdl"
    }
  }
}
