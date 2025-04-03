locals {
  key_vault_name = coalesce(var.key_vault_name, module.naming.key_vault.name)

  key_vault_private_endpoints = {
    primary = {
      name                          = "${module.naming.private_endpoint.name}-kv"
      private_dns_zone_resource_ids = [module.private_dns_zone["key_vault"].resource_id]
      subnet_resource_id            = module.virtual_network.subnets["private-endpoints-subnet"].resource_id
      tags = merge(local.tags, {
        "Resource_Type" = "Private Endpoint",
        "Resource_Name" = "${module.naming.private_endpoint.name}-kv"
      })
    }
  }

  key_vault_role_assignments = {
    "aks_secrets_user" = {
      principal_id               = module.managed_identity["aks"].principal_id
      role_definition_id_or_name = "Key Vault Secrets User"
    }
  }

  key_vault_tags = merge(local.tags, {
    "Resource_Type" = "Key Vault",
    "Resource_Name" = local.key_vault_name
  })
}

module "keyvault" {
  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  name                          = local.key_vault_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku_name                      = var.key_vault_sku_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  network_acls                  = var.key_vault_network_acls
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  private_endpoints             = local.key_vault_private_endpoints
  role_assignments              = local.key_vault_role_assignments
  diagnostic_settings           = local.diagnostic_settings
  enable_telemetry              = local.enable_telemetry
  tags                          = local.key_vault_tags
}
