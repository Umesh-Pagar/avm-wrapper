
network_profile = {
  dns_service_ip = "10.10.200.10"
  service_cidr   = "10.10.200.0/24"
  network_plugin = "azure"
  network_policy = "azure"
}

private_cluster_enabled = true
kubernetes_version      = "1.31"

aks_managed_identities = {
  system_assigned = false
}

azure_active_directory_role_based_access_control = {
  azure_rbac_enabled = true
}

default_node_pool = {
  name                         = "default"
  vm_size                      = "Standard_DS3_v2"
  auto_scaling_enabled         = true
  max_count                    = 5
  min_count                    = 1
  only_critical_addons_enabled = true
  upgrade_settings = {
    max_surge = "10%"
  }
}

node_pools = {
  unp1 = {
    name                 = "userpool1"
    vm_size              = "Standard_DS3_v2"
    auto_scaling_enabled = true
    max_count            = 5
    min_count            = 1
    upgrade_settings = {
      max_surge = "10%"
    }
  }
  # unp2 = {
  #   name                 = "userpool2"
  #   vm_size              = "Standard_DS3_v2"
  #   zones                = [3]
  #   auto_scaling_enabled = true
  #   max_count            = 5
  #   min_count            = 1
  #   upgrade_settings = {
  #     max_surge = "10%"
  #   }
  # }
}