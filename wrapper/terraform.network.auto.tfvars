virtual_network_address_space = ["10.0.0.0/20"]

# Network Security Groups with rules
network_security_groups = {
  web = {
    name = "web"
    security_rules = {
      allow-http = {
        name                       = "allow-http"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      allow-https = {
        name                       = "allow-https"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      allow-ssh = {
        name                       = "allow-ssh"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.0.0/8"
        destination_address_prefix = "*"
      }
    }
  },
  app = {
    name = "app"
    security_rules = {
      allow-web-subnet = {
        name                       = "allow-web-subnet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "10.0.1.0/24" # Web subnet CIDR
        destination_address_prefix = "*"
      },
      allow-mgmt = {
        name                       = "allow-mgmt"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.0.0/8"
        destination_address_prefix = "*"
      }
    }
  },
  db = {
    name = "db"
    security_rules = {
      allow-app-subnet = {
        name                       = "allow-app-subnet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "10.0.2.0/24" # App subnet CIDR
        destination_address_prefix = "*"
      },
      deny-internet = {
        name                       = "deny-internet"
        priority                   = 4000
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      }
    }
  }
}

# Subnets that will be linked to NSGs based on matching names
virtual_network_subnets = {
  web-subnet = {
    name                            = "web" # Matches NSG key, will be linked automatically
    address_prefixes                = ["10.0.1.0/24"]
    default_outbound_access_enabled = true
  },
  app-subnet = {
    name                            = "app" # Matches NSG key, will be linked automatically
    address_prefixes                = ["10.0.2.0/24"]
    default_outbound_access_enabled = true
  },
  db-subnet = {
    name             = "db" # Matches NSG key, will be linked automatically
    address_prefixes = ["10.0.3.0/24"]
    delegation = [{
      name = "sqlmi"
      service_delegation = {
        name = "Microsoft.Sql/managedInstances"
      }
    }]
  },
  private-endpoints-subnet = {
    name                                          = "pe" # No matching NSG
    address_prefixes                              = ["10.0.4.0/24"]
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = false
  }
  gateway-subnet = {
    name             = "GatewaySubnet" # Azure requires this specific name for VPN Gateway
    address_prefixes = ["10.0.0.0/27"]
  }
  aks_node_subnet = {
    name             = "aks-node"
    address_prefixes = ["10.0.5.0/24"] // 32 IPs for user node pools
  }
  agw_subnet = {
    name             = "agw"
    address_prefixes = ["10.0.6.0/24"] // 32 IPs for Application Gateway
  }
}

private_dns_zones = {
  azure_monitor = {
    domain_name = "privatelink.monitor.azure.com"
  }
  ods_log_analytics = {
    domain_name = "privatelink.ods.opinsights.azure.com"
  }
  oms_log_analytics = {
    domain_name = "privatelink.oms.opinsights.azure.com"
  }
  automation = {
    domain_name = "privatelink.agentsvc.azure-automation.net"
  }
  storage = {
    domain_name = "privatelink.blob.core.windows.net"
  }
  key_vault = {
    domain_name = "privatelink.vault.azure.net"
  }
  container_registry = {
    domain_name = "privatelink.azurecr.io"
  }
  aks = {
    domain_name = "privatelink.eastus.azmk8s.io"
  }
}