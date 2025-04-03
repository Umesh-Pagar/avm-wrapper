locals {
  aks_name                   = coalesce(var.aks_name, module.naming.kubernetes_cluster.name)
  node_resource_group_name   = coalesce(var.node_resource_group_name, "${local.resource_group_name}-aks")
  dns_prefix                 = coalesce(var.dns_prefix, local.aks_name)
  dns_prefix_private_cluster = coalesce(var.dns_prefix_private_cluster, local.aks_name)

  aks_managed_identities = var.aks_managed_identities.system_assigned ? {
    system_assigned            = true
    user_assigned_resource_ids = []
    } : {
    system_assigned            = false
    user_assigned_resource_ids = [module.managed_identity["aks"].resource_id]
  }

  kubelet_identity = {
    client_id                 = module.managed_identity["aks"].client_id
    object_id                 = module.managed_identity["aks"].principal_id
    user_assigned_identity_id = module.managed_identity["aks"].resource_id
  }

  web_app_routing_dns_zone_ids = {
    dns_zone_id = [module.private_dns_zone["aks"].resource_id]
  }

  oms_agent = var.oms_agent != null ? var.oms_agent : {
    log_analytics_workspace_id = module.log_analytics_workspace.resource_id
  }

  azure_active_directory_role_based_access_control = merge(var.azure_active_directory_role_based_access_control, {
    tenant_id = data.azurerm_client_config.current.tenant_id
  })

  default_node_pool = merge(var.default_node_pool, {
    vnet_subnet_id = module.virtual_network.subnets["aks_node_subnet"].resource_id
    tags           = local.aks_tags
  })

  node_pools = merge(var.node_pools, {
    for key, node_pool in var.node_pools : key => merge(node_pool, {
      vnet_subnet_id = module.virtual_network.subnets["aks_node_subnet"].resource_id
      tags           = local.aks_tags
    })
  })

  aks_tags = merge(local.tags, {
    "Resource_Type" = "Azure Kubernetes Service"
    "AKS_Name"      = local.aks_name
  })
}

module "azure_kubernetes_service" {
  source                                           = "Azure/avm-res-containerservice-managedcluster/azurerm"
  name                                             = local.aks_name
  resource_group_name                              = local.resource_group_name
  node_resource_group_name                         = local.node_resource_group_name
  location                                         = local.location
  sku_tier                                         = var.aks_sku_tier
  kubernetes_version                               = var.kubernetes_version
  private_cluster_enabled                          = var.private_cluster_enabled
  dns_prefix_private_cluster                       = local.dns_prefix_private_cluster
  private_dns_zone_id                              = module.private_dns_zone["aks"].resource_id
  managed_identities                               = local.aks_managed_identities
  kubelet_identity                                 = local.kubelet_identity
  network_profile                                  = var.network_profile
  web_app_routing_dns_zone_ids                     = local.web_app_routing_dns_zone_ids
  oms_agent                                        = local.oms_agent
  azure_active_directory_role_based_access_control = local.azure_active_directory_role_based_access_control
  local_account_disabled                           = var.local_account_disabled
  defender_log_analytics_workspace_id              = module.log_analytics_workspace.resource_id
  default_node_pool                                = local.default_node_pool
  node_pools                                       = local.node_pools
  linux_profile                                    = var.linux_profile
  key_vault_secrets_provider                       = var.key_vault_secrets_provider
  oidc_issuer_enabled                              = var.oidc_issuer_enabled
  workload_identity_enabled                        = var.workload_identity_enabled
  workload_autoscaler_profile                      = var.workload_autoscaler_profile
  automatic_upgrade_channel                        = var.automatic_upgrade_channel
  node_os_channel_upgrade                          = var.node_os_channel_upgrade
  diagnostic_settings                              = local.diagnostic_settings
  enable_telemetry                                 = local.enable_telemetry
  tags                                             = local.aks_tags
  depends_on                                       = [module.role_assignments, module.private_dns_zone]
}
