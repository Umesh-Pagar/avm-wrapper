# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = ["${lower(var.brand)}", "${lower(var.application)}", "${lower(var.environment)}", "${lower(var.location)}"]
}

module "resource_group" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  name             = local.resource_group_name
  location         = local.location
  enable_telemetry = local.enable_telemetry
  tags             = local.tags
}