locals {
  acr_name                          = coalesce(var.acr_name, module.naming.container_registry.name)
  acr_zone_redundancy_enabled       = var.acr_sku == "Premium" ? var.acr_zone_redundancy_enabled : false
  acr_georeplications               = var.acr_sku == "Premium" ? var.acr_georeplications : []
  acr_retention_policy_in_days      = var.acr_sku == "Premium" ? var.acr_retention_policy_in_days : null
  acr_public_network_access_enabled = var.acr_sku == "Premium" ? var.acr_public_network_access_enabled : true

  acr_private_endpoints = var.acr_sku == " Premium" ? {
    primary = {
      name                          = "${module.naming.private_endpoint.name}-acr"
      private_dns_zone_resource_ids = [module.private_dns_zone["container_registry"].resource_id]
      subnet_resource_id            = module.virtual_network.subnets["private-endpoints-subnet"].resource_id
      tags = merge(local.tags, {
        "Resource_Type" = "Private Endpoint",
        "Resource_Name" = "${module.naming.private_endpoint.name}-acr"
      })
    }
  } : null

  acr_role_assignments = merge(var.acr_role_assignments, {
    aks_acr_pull = {
      principal_id               = module.managed_identity["aks"].principal_id
      role_definition_id_or_name = "AcrPull"
    }
  })

  acr_tags = merge(local.tags, {
    "Resource_Type" = "Container Registry",
    "Resource_Name" = local.acr_name
  })
}

module "container_registry" {
  source                        = "Azure/avm-res-containerregistry-registry/azurerm"
  name                          = local.acr_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = var.acr_sku
  zone_redundancy_enabled       = local.acr_zone_redundancy_enabled
  georeplications               = local.acr_georeplications
  retention_policy_in_days      = local.acr_retention_policy_in_days
  public_network_access_enabled = local.acr_public_network_access_enabled
  private_endpoints             = local.acr_private_endpoints
  network_rule_bypass_option    = var.acr_network_rule_bypass_option
  network_rule_set              = var.acr_network_rule_set
  managed_identities            = var.acr_managed_identities
  role_assignments              = local.acr_role_assignments
  diagnostic_settings           = local.diagnostic_settings
  enable_telemetry              = local.enable_telemetry
  tags                          = local.acr_tags
}
