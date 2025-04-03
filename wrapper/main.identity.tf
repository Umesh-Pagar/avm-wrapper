locals {
  user_assigned_managed_identities = {
    for key, uami in var.user_assigned_managed_identities : key => merge(uami, {
      name = "${module.naming.user_assigned_identity.name}-${uami.name}"
      tags = merge(local.tags, {
        "Resource_Type" = "User Assigned Managed Identity",
        "Resource_Name" = "${module.naming.user_assigned_identity.name}-${uami.name}"
      })
    })
  }

  role_definitions = {}
  role_assignments_azure_resource_manager = {
    aks_dns_zone = {
      scope                = module.private_dns_zone["aks"].resource_id
      role_definition_name = "Private DNS Zone Contributor"
      principal_id         = module.managed_identity["aks"].principal_id
    }
    aks_node_subnet = {
      scope                = module.virtual_network.subnets["aks_node_subnet"].resource_id
      role_definition_name = "Network Contributor"
      principal_id         = module.managed_identity["aks"].principal_id
    }
    aks_kubelet_identity = {
      scope                = module.managed_identity["aks"].resource_id
      role_definition_name = "Managed Identity Operator"
      principal_id         = module.managed_identity["aks"].principal_id
    }
  }
  role_assignments_for_subscriptions              = {}
  role_assignments_for_resource_groups            = {}
  role_assignments_for_resources                  = {}
  role_assignments_for_scopes                     = {}
  system_assigned_managed_identities_by_client_id = {}
  user_assigned_managed_identities_by_client_id   = {}
}

module "managed_identity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  for_each            = local.user_assigned_managed_identities
  resource_group_name = local.resource_group_name
  location            = local.location
  name                = each.value.name
  enable_telemetry    = local.enable_telemetry
  tags = merge(local.tags, {
    "Resource_Type" = "User Assigned Managed Identity",
    "Resource_Name" = each.value.name
  })
  depends_on = [module.resource_group]
}

module "role_assignments" {
  source                                          = "Azure/avm-res-authorization-roleassignment/azurerm"
  role_definitions                                = local.role_definitions
  role_assignments_azure_resource_manager         = local.role_assignments_azure_resource_manager
  role_assignments_for_subscriptions              = local.role_assignments_for_subscriptions
  role_assignments_for_resource_groups            = local.role_assignments_for_resource_groups
  role_assignments_for_resources                  = local.role_assignments_for_resources
  role_assignments_for_scopes                     = local.role_assignments_for_scopes
  system_assigned_managed_identities_by_client_id = local.user_assigned_managed_identities_by_client_id
  user_assigned_managed_identities_by_client_id   = local.user_assigned_managed_identities_by_client_id
  enable_telemetry                                = local.enable_telemetry
}
