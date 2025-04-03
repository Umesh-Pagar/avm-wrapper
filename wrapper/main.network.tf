locals {
  virtual_network_name  = coalesce(var.virtual_network_name, module.naming.virtual_network.name)
  reserved_subnet_names = ["GatewaySubnet", "AzureFirewallSubnet", "AzureBastionSubnet", "RouteServerSubnet", "AzureFirewallManagementSubnet"]

  network_security_groups = {
    for key, nsg in var.network_security_groups : key => merge(nsg, {
      name = "${module.naming.network_security_group.name}-${nsg.name}"
      tags = merge(local.tags, {
        "Resource_Type" = "Network Security Group",
        "Resource_Name" = nsg.name
      })
    }) if !contains(local.reserved_subnet_names, nsg.name)
  }

  virtual_network_subnets = {
    for key, subnet in var.virtual_network_subnets : key => merge(subnet, {
      name = contains(local.reserved_subnet_names, subnet.name) ? subnet.name : "${module.naming.subnet.name}-${subnet.name}",

      network_security_group = contains(local.reserved_subnet_names, subnet.name) ? null : (
        contains(keys(var.network_security_groups), subnet.name) ? {
        id = module.network_security_group[subnet.name].resource_id } : subnet.network_security_group
      )
    })
  }

  # subnet_nsg_mapping = {
  #   for key, subnet in var.virtual_network_subnets : key =>
  #   contains(local.reserved_subnet_names, subnet.name) ? null :
  #   contains(keys(local.network_security_groups), subnet.name) ? {
  #     id = module.network_security_group[subnet.name].resource_id
  #   } : subnet.network_security_group
  # }

  # virtual_network_subnets = {
  #   for key, subnet in var.virtual_network_subnets : key => merge(subnet, {
  #     name = contains(local.reserved_subnet_names, subnet.name) ? subnet.name : "${module.naming.subnet.name}-${subnet.name}",
  #     network_security_group = local.subnet_nsg_mapping[key]
  #   })
  # }

  virtual_network_tags = merge(local.tags, {
    "Resource_Type" = "Virtual Network",
    "Resource_Name" = local.virtual_network_name
  })

  # ------------- Private DNS Zones -------------
  private_dns_zones = {
    for key, zone in var.private_dns_zones : key => merge(zone, {
      resource_group_name = zone.resource_group_name != null ? zone.resource_group_name : local.resource_group_name
      virtual_network_links = merge(
        zone.virtual_network_links,
        {
          "virtual_network_primary" = {
            vnetlinkname = "vnet-link-${module.virtual_network.name}"
            vnetid       = module.virtual_network.resource_id
          }
        }
      )
      tags = merge(local.tags, {
        "Resource_Type" = "Private DNS Zone",
        "Resource_Name" = zone.domain_name
      })
    })
  }
}

# ------------- Virtual Network -------------
# This module creates a virtual network in Azure with the specified address space and subnets.
module "virtual_network" {
  source                  = "Azure/avm-res-network-virtualnetwork/azurerm"
  resource_group_name     = local.resource_group_name
  location                = local.location
  name                    = local.virtual_network_name
  address_space           = var.virtual_network_address_space
  dns_servers             = var.virtual_network_dns_servers
  ddos_protection_plan    = var.virtual_network_ddos_protection_plan
  role_assignments        = var.virtual_network_role_assignments
  enable_vm_protection    = var.virtual_network_enable_vm_protection
  encryption              = var.virtual_network_encryption
  flow_timeout_in_minutes = var.virtual_network_flow_timeout_in_minutes
  subnets                 = local.virtual_network_subnets
  diagnostic_settings     = local.diagnostic_settings
  enable_telemetry        = local.enable_telemetry
  tags                    = local.virtual_network_tags
  depends_on              = [module.resource_group]
}

# ------------- Network Security Groups -------------
# This module creates network security groups in Azure with the specified security rules.
module "network_security_group" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  for_each            = local.network_security_groups
  resource_group_name = local.resource_group_name
  location            = local.location
  name                = each.value.name
  security_rules      = each.value.security_rules
  role_assignments    = each.value.role_assignments
  timeouts            = each.value.timeouts
  diagnostic_settings = each.value.diagnostic_settings
  enable_telemetry    = local.enable_telemetry
  tags                = each.value.tags
  depends_on          = [module.resource_group]
}

# ------------- Private DNS Zones -------------
# This module creates private DNS zones in Azure and links them to the specified virtual networks.
module "private_dns_zone" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"
  for_each              = local.private_dns_zones
  resource_group_name   = local.resource_group_name
  domain_name           = each.value.domain_name
  virtual_network_links = each.value.virtual_network_links
  enable_telemetry      = local.enable_telemetry
  tags                  = each.value.tags
}
