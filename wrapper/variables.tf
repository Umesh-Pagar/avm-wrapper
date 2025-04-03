variable "subscription_id" {
  type        = string
  default     = null
  description = "(Optional) Subscription ID passed in by an external process.  If this is not supplied, then the configuration either needs to include the subscription ID, or needs to be supplied properties to create the subscription."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = <<DESCRIPTION
(Required) The name of the resource group where the resources will be deployed. 
DESCRIPTION
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
(Optional) The location/region where the virtual network is created. Changing this forces a new resource to be created. 
DESCRIPTION
  nullable    = false
}

variable "brand" {
  type        = string
  description = "(Required) The name of the brand."
  nullable    = false
}

variable "application" {
  type        = string
  description = "(Required) The name of the application."
  nullable    = false
}

variable "environment" {
  type        = string
  description = "(Required) The environment in which the infrastructure is deployed."
  nullable    = false

  validation {
    condition     = can(regex("^(dev|qa|uat|prod)$", var.environment))
    error_message = "The environment must be either dev, qa, uat, or prod."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetry.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}


variable "user_assigned_managed_identities" {
  type = map(object({
    name = string
  }))
  default     = null
  description = "(Optional) User assigned managed identities to be created."
}