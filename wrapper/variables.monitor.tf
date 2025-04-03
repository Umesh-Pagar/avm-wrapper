variable "log_analytics_workspace_name" {
  type        = string
  description = "Specifies the name of the Log Analytics Workspace. Changing this forces a new resource to be created."
  default     = null

  validation {
    condition     = var.log_analytics_workspace_name || can(regex("^[A-Za-z0-9][A-Za-z0-9-]{2,61}[A-Za-z0-9]$", var.log_analytics_workspace_name))
    error_message = "The name must be a valid Log Analytics Workspace name."
  }
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "log_analytics_workspace_customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "log_analytics_workspace_diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
  - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
  - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
  DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.log_analytics_workspace_diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.log_analytics_workspace_diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "log_analytics_workspace_allow_resource_only_permissions" {
  type        = bool
  default     = null
  description = "(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to `true`."
}

variable "log_analytics_workspace_cmk_for_query_forced" {
  type        = bool
  default     = null
  description = "(Optional) Is Customer Managed Storage mandatory for query management?"
}

variable "log_analytics_workspace_daily_quota_gb" {
  type        = number
  default     = null
  description = "(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted."
}

variable "log_analytics_workspace_identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default = {
    type = "SystemAssigned"
  }
  description = <<-EOT
 - `identity_ids` - (Optional) Specifies a list of user managed identity ids to be assigned. Required if `type` is `UserAssigned`.
 - `type` - (Required) Specifies the identity type of the Log Analytics Workspace. Possible values are `SystemAssigned` (where Azure will generate a Service Principal for you) and `UserAssigned` where you can specify the Service Principal IDs in the `identity_ids` field.
EOT
}

variable "log_analytics_workspace_internet_ingestion_enabled" {
  type        = bool
  default     = "false"
  description = "(Required) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to `False`."
}

variable "log_analytics_workspace_internet_query_enabled" {
  type        = bool
  default     = "false"
  description = "(Required) Should the Log Analytics Workspace support querying over the Public Internet? Defaults to `False`."
}

variable "log_analytics_workspace_local_authentication_disabled" {
  type        = bool
  default     = null
  description = "(Optional) Specifies if the log Analytics workspace should enforce authentication using Azure AD. Defaults to `false`."
}

variable "log_analytics_workspace_reservation_capacity_in_gb_per_day" {
  type        = number
  default     = null
  description = "(Optional) The capacity reservation level in GB for this workspace. Possible values are `100`, `200`, `300`, `400`, `500`, `1000`, `2000` and `5000`."
}

variable "log_analytics_workspace_retention_in_days" {
  type        = number
  default     = null
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = null
  description = "(Optional) Specifies the SKU of the Log Analytics Workspace. Possible values are `Free`, `PerNode`, `Premium`, `Standard`, `Standalone`, `Unlimited`, `CapacityReservation`, and `PerGB2018` (new SKU as of `2018-04-03`). Defaults to `PerGB2018`."
}

variable "log_analytics_workspace_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
 - `create` - (Defaults to 30 minutes) Used when creating the Log Analytics Workspace.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Log Analytics Workspace.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Log Analytics Workspace.
 - `update` - (Defaults to 30 minutes) Used when updating the Log Analytics Workspace.
DESCRIPTION
}

variable "monitor_private_link_scope" {
  type = map(object({
    name        = optional(string)
    resource_id = string
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of Monitor Private Link Scopes to create on the Log Analytics Workspace. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the Monitor Private Link Scope. One will be generated if not set.
  - `resource_id` - The resource ID of the Monitor Private Link Scope to create.
  DESCRIPTION
  nullable    = false
}

variable "monitor_private_link_scoped_resource" {
  type = map(object({
    name        = optional(string)
    resource_id = string
  }))
  default     = {}
  description = <<DESCRIPTION
 - `name` - Defaults to the name of the Log Analytics Workspace.
 - `resource_id` - Resource ID of an existing Monitor Private Link Scope to connect to.
DESCRIPTION
}

variable "monitor_private_link_scoped_service_name" {
  type        = string
  default     = null
  description = "The name of the service to connect to the Monitor Private Link Scope."
}

variable "log_analytics_workspace_private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `name` - (Optional) The name of the private endpoint. One will be generated if not set.
  - `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
  - `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
  - `tags` - (Optional) A mapping of tags to assign to the private endpoint.
  - `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
  - `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
  - `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
  - `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
  - `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
  - `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
  - `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.
  - `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - The name of the IP configuration.
    - `private_ip_address` - The private IP address of the IP configuration.
  DESCRIPTION
  nullable    = false
}

variable "log_analytics_workspace_private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "log_analytics_workspace_role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  
  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

# -------------- Application Insights --------------
variable "application_insights" {
  type = map(object({
    name                                  = string
    application_type                      = string
    workspace_id                          = optional(string, null)
    local_authentication_disabled         = optional(bool, false)
    internet_ingestion_enabled            = optional(bool, false)
    internet_query_enabled                = optional(bool, false)
    retention_in_days                     = optional(number, 90)
    sampling_percentage                   = optional(number, 100)
    daily_data_cap_in_gb                  = optional(number, 100)
    daily_data_cap_notifications_disabled = optional(bool, false)
    disable_ip_masking                    = optional(bool, false)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of Application Insights resources to create. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - The name of the Application Insights resource.
  - `application_type` - The type of the application. Possible values are `web`, `ios`, `java`, `phone`, `MobileCenter`, `other`, `store`.
  - `workspace_id` - The ID of the Log Analytics workspace to send data to.
  - `local_authentication_disabled` - (Optional) Disables local authentication. Defaults to false.
  - `internet_ingestion_enabled` - (Optional) Enables internet ingestion. Defaults to false.
  - `internet_query_enabled` - (Optional) Enables internet query. Defaults to false.
  - `retention_in_days` - (Optional) The retention period in days. 0 means unlimited.
  - `sampling_percentage` - (Optional) The sampling percentage. 100 means all.
  - `daily_data_cap_in_gb` - (Optional) The daily data cap in GB. 0 means unlimited.
  - `daily_data_cap_notifications_disabled` - (Optional) Disables the daily data cap notifications.
  - `disable_ip_masking` - (Optional) Disables IP masking. Defaults to false. For more information see <https://aka.ms/avm/ipmasking>.
  DESCRIPTION

  validation {
    condition     = alltrue([for _, v in var.application_insights : can(regex("^[A-Za-z0-9._()-]{1,254}[A-Za-z0-9_()-]$", v.name))])
    error_message = "The name must be between 5 and 50 characters long and can only contain lowercase letters and numbers."
  }
  validation {
    condition     = alltrue([for _, v in var.application_insights : contains(["ios", "java", "MobileCenter", "other", "phone", "store", "web"], v.application_type)])
    error_message = "Invalid value for application type. Valid options are 'web', 'ios', 'java', 'phone', 'MobileCenter', 'other', 'store'."
  }
}

# variable "application_insights_name" {
#   type        = string
#   description = "The name of the this resource."
#   default     = null

#   validation {
#     condition     = can(regex("^[A-Za-z0-9._()-]{1,254}[A-Za-z0-9_()-]$", var.application_insights_name))
#     error_message = "The name must be between 5 and 50 characters long and can only contain lowercase letters and numbers."
#   }
# }

variable "workspace_id" {
  type        = string
  default     = null
  description = "(Required) The ID of the Log Analytics workspace to send data to. AzureRm supports classic; however, Azure has deprecated it, thus it's required"
}

variable "application_insights_application_type" {
  type        = string
  default     = "web"
  description = "(Required) The type of the application. Possible values are 'web', 'ios', 'java', 'phone', 'MobileCenter', 'other', 'store'."

  validation {
    condition     = contains(["ios", "java", "MobileCenter", "other", "phone", "store", "web"], var.application_insights_application_type)
    error_message = "Invalid value for replication type. Valid options are 'web', 'ios', 'java', 'phone', 'MobileCenter', 'other', 'store'."
  }
}

# Optional Variables
variable "application_insights_daily_data_cap_in_gb" {
  type        = number
  default     = 100
  description = "(Optional) The daily data cap in GB. 0 means unlimited."
}

variable "daily_data_cap_notifications_disabled" {
  type        = bool
  default     = false
  description = "(Optional) Disables the daily data cap notifications."
}

variable "application_insights_disable_ip_masking" {
  type        = bool
  default     = false
  description = "(Optional) Disables IP masking. Defaults to false. For more information see <https://aka.ms/avm/ipmasking>."
}

variable "application_insights_internet_ingestion_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enables internet ingestion. Defaults to false."
}

variable "application_insights_internet_query_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enables internet query. Defaults to false."
}

variable "application_insights_local_authentication_disabled" {
  type        = bool
  default     = false
  description = "(Optional) Disables local authentication. Defaults to false."
}

# tflint-ignore: terraform_unused_declarations
variable "application_insights_managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:
  
  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
}

variable "application_insights_retention_in_days" {
  type        = number
  default     = 90
  description = "(Optional) The retention period in days. 0 means unlimited."
}

variable "application_insights_sampling_percentage" {
  type        = number
  default     = 100
  description = "(Optional) The sampling percentage. 100 means all."
}
