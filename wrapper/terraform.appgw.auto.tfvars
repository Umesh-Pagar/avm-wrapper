agw_sku = {
  name     = "WAF_v2"
  tier     = "WAF_v2"
  capacity = 0 # 0 = autoscale
}

agw_managed_identities = {
  system_assigned = true
}

agw_autoscale_configuration = {
  min_capacity = 2
  max_capacity = 5
}

agw_frontend_ports = {
  frontend-port-443 = {
    name = "frontend-port-443"
    port = 443
  }
  # frontend-port-80 = {
  #   name = "frontend-port-80"
  #   port = 80
  # }
}

agw_backend_address_pools = {
  default = {
    name = "default"
  }
}

agw_backend_http_settings = {
  default = {
    name            = "default"
    port            = 80
    protocol        = "Http"
    request_timeout = 30
    connection_draining = {
      enable_connection_draining = true
      drain_timeout_sec          = 300
    }
  }
}

agw_http_listeners = {
  default = {
    name                           = "default"
    frontend_ip_configuration_name = "default"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }
}

agw_request_routing_rules = {
  routing-rule-1 = {
    name                       = "rule-1"
    rule_type                  = "Basic"
    http_listener_name         = "default"
    backend_address_pool_name  = "default"
    backend_http_settings_name = "default"
    priority                   = 100
    rewrite_rule_set_name      = "my-rewrite-rule-set"
  }
  # Add more rules as needed
}

agw_rewrite_rule_set = {
  hsts = {
    name = "hsts-header-rewrite"
    rewrite_rules = {
      rule_1 = {
        name          = "hsts-rewrite"
        rule_sequence = 102
        # request_header_configurations = {
        #   x-forwarded-for = {
        #     header_name  = "X-Forwarded-For"
        #     header_value = "{var_client_ip}"
        #   }
        # }
        response_header_configurations = {
          hsts = {
            header_name  = "Strict-Transport-Security"
            header_value = "max-age=31536000; includeSubDomains"
          }
        }
      }
    }
  }
}

agw_ssl_policy = {
  min_protocol_version = "TLSv1_2"
  policy_type          = "CustomV2"
  cipher_suites = [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
  ]

}