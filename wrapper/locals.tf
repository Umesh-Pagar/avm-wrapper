locals {
  resource_group_name = coalesce(var.resource_group_name, module.naming.resource_group.name)
  location            = coalesce(var.location, "eastus")

  # ------------- Diagnostic Settings -------------
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                  = "sendToLogAnalytics"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  enable_telemetry = var.enable_telemetry != null ? var.enable_telemetry : true
  tags = merge(
    var.tags,
    {
      Brand       = var.brand
      Application = var.application
      Environment = var.environment
    }
  )
}
