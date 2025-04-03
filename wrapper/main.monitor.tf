locals {
  log_analytics_workspace_name = coalesce(var.log_analytics_workspace_name, module.naming.log_analytics_workspace.name)
  # ------------- Application Insights -------------
  application_insights = {
    for key, app_insight in var.application_insights : key => merge(app_insight, {
      name = "${module.naming.application_insights.name}-${app_insight.name}"
      tags = merge(local.tags, {
        "Resource_Type" = "Application Insights",
        "Resource_Name" = app_insight.name
      })
    })
  }

  log_analytics_workspace_tags = merge(local.tags, {
    "Resource_Type" = "Log Analytics Workspace",
    "Resource_Name" = local.log_analytics_workspace_name
  })
}
module "log_analytics_workspace" {
  source                                                = "Azure/avm-res-operationalinsights-workspace/azurerm"
  resource_group_name                                   = local.resource_group_name
  location                                              = local.location
  name                                                  = local.log_analytics_workspace_name
  log_analytics_workspace_retention_in_days             = var.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku                           = var.log_analytics_workspace_sku
  log_analytics_workspace_identity                      = var.log_analytics_workspace_identity
  log_analytics_workspace_internet_ingestion_enabled    = var.log_analytics_workspace_internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled        = var.log_analytics_workspace_internet_query_enabled
  log_analytics_workspace_local_authentication_disabled = var.log_analytics_workspace_local_authentication_disabled
  monitor_private_link_scope                            = var.monitor_private_link_scope
  monitor_private_link_scoped_resource                  = var.monitor_private_link_scoped_resource
  monitor_private_link_scoped_service_name              = var.monitor_private_link_scoped_service_name
  enable_telemetry                                      = local.enable_telemetry
  tags                                                  = local.log_analytics_workspace_tags
  depends_on                                            = [module.resource_group]
}

module "application_insights" {
  source                        = "Azure/avm-res-insights-component/azurerm"
  for_each                      = local.application_insights
  location                      = local.location
  resource_group_name           = local.resource_group_name
  name                          = each.value.name
  application_type              = each.value.application_type
  workspace_id                  = module.log_analytics_workspace.resource_id
  local_authentication_disabled = var.application_insights_local_authentication_disabled
  internet_ingestion_enabled    = var.application_insights_internet_ingestion_enabled
  internet_query_enabled        = var.application_insights_internet_query_enabled
  enable_telemetry              = local.enable_telemetry
  tags                          = each.value.tags
}
