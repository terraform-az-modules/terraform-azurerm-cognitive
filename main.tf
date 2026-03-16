##-----------------------------------------------------------------------------
# Standard Tagging Module – Applies standard tags to all resources for traceability
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##-----------------------------------------------------------------------------
## Cognitive Account Resource
##-----------------------------------------------------------------------------
resource "azurerm_cognitive_account" "main" {
  count                                        = var.enabled ? 1 : 0
  name                                         = var.resource_position_prefix ? format("foundry-%s", local.name) : format("%s-foundry", local.name)
  location                                     = var.location
  resource_group_name                          = var.resource_group_name
  kind                                         = var.kind
  sku_name                                     = var.sku_name
  tags                                         = module.labels.tags
  custom_subdomain_name                        = var.custom_subdomain_name
  dynamic_throttling_enabled                   = var.dynamic_throttling_enabled
  fqdns                                        = var.fqdns
  local_auth_enabled                           = var.local_auth_enabled
  metrics_advisor_aad_client_id                = var.metrics_advisor_aad_client_id
  metrics_advisor_aad_tenant_id                = var.metrics_advisor_aad_tenant_id
  metrics_advisor_super_user_name              = var.metrics_advisor_super_user_name
  metrics_advisor_website_name                 = var.metrics_advisor_website_name
  outbound_network_access_restricted           = var.outbound_network_access_restricted
  public_network_access_enabled                = var.public_network_access_enabled
  qna_runtime_endpoint                         = var.qna_runtime_endpoint
  custom_question_answering_search_service_id  = var.custom_question_answering_search_service_id
  custom_question_answering_search_service_key = var.custom_question_answering_search_service_key
  project_management_enabled                   = var.project_management_enabled

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action = network_acls.value.default_action
      ip_rules       = network_acls.value.ip_rules
      bypass         = network_acls.value.bypass

      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules != null ? network_acls.value.virtual_network_rules : []
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }
  identity {
    type         = var.enable_customer_managed_key ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.enable_customer_managed_key ? [azurerm_user_assigned_identity.main[0].id] : null
  }

  dynamic "customer_managed_key" {
    for_each = var.enable_customer_managed_key ? [1] : []
    content {
      key_vault_key_id   = azurerm_key_vault_key.main[0].id
      identity_client_id = azurerm_user_assigned_identity.main[0].client_id
    }
  }

  dynamic "storage" {
    for_each = var.storage == null ? [] : [var.storage]
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
  }

  dynamic "network_injection" {
    for_each = var.network_injection != null ? [var.network_injection] : []
    content {
      scenario  = network_injection.value.scenario
      subnet_id = network_injection.value.subnet_id
    }
  }
  lifecycle {
    ignore_changes = []
  }
}

##-----------------------------------------------------------------------------
## User Assigned Identity
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "main" {
  count               = var.enabled && var.enable_customer_managed_key ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.resource_position_prefix ? format("mid-%s", local.name) : format("%s-mid", local.name)
  tags                = module.labels.tags
}

resource "azurerm_role_assignment" "identity_assigned" {
  # provider             = azurerm.main_sub
  depends_on           = [azurerm_user_assigned_identity.main]
  count                = var.enabled && var.enable_customer_managed_key ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each             = toset(var.enabled && var.enable_customer_managed_key ? var.admin_objects_ids : [])
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

##-----------------------------------------------------------------------------
## Key Vault Key
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "main" {
  depends_on      = [azurerm_role_assignment.identity_assigned]
  count           = var.enabled && var.enable_customer_managed_key ? 1 : 0
  name            = var.resource_position_prefix ? format("kvk-%s", local.name) : format("%s-kvk", local.name)
  key_vault_id    = var.key_vault_id
  key_type        = var.key_type
  key_size        = var.key_size
  key_opts        = var.key_opts
  expiration_date = var.key_expiration_date
  tags            = module.labels.tags

  dynamic "rotation_policy" {
    for_each = var.rotation_policy_config.enabled ? [1] : []
    content {
      automatic {
        time_before_expiry = var.rotation_policy_config.time_before_expiry
      }
      expire_after         = var.rotation_policy_config.expire_after
      notify_before_expiry = var.rotation_policy_config.notify_before_expiry
    }
  }
}


##-----------------------------------------------------------------------------
## Cognitive Deployment
##-----------------------------------------------------------------------------
resource "azurerm_cognitive_deployment" "main" {
  count                  = var.enabled && var.enable_deployment ? 1 : 0
  name                   = var.resource_position_prefix ? format("cd-%s", local.name) : format("%s-cd", local.name)
  cognitive_account_id   = azurerm_cognitive_account.main[0].id
  rai_policy_name        = var.deployment_rai_policy_name
  version_upgrade_option = var.deployment_version_upgrade_option

  model {
    format  = var.deployment_model.format
    name    = var.deployment_model.name
    version = var.deployment_model.version
  }

  sku {
    name     = var.deployment_sku.name
    capacity = var.deployment_sku.capacity
  }
}

##-----------------------------------------------------------------------------
## Cognitive Project
##-----------------------------------------------------------------------------
resource "azurerm_cognitive_account_project" "main" {
  count                = var.enabled && var.enable_project ? 1 : 0
  name                 = var.resource_position_prefix ? format("proj-%s", local.name) : format("%s-proj", local.name)
  cognitive_account_id = azurerm_cognitive_account.main[0].id
  location             = coalesce(var.project_location, var.location)
  description          = var.project_description
  display_name         = var.project_display_name
  tags                 = merge(module.labels.tags, var.project_tags)

  identity {
    type         = var.project_identity != null ? var.project_identity.type : "SystemAssigned"
    identity_ids = try(length(var.project_identity.identity_ids) > 0 ? var.project_identity.identity_ids : null, null)
  }
}

##-----------------------------------------------------------------------------
## RAI Blocklist and Policy
##-----------------------------------------------------------------------------
resource "azurerm_cognitive_account_rai_blocklist" "main" {
  count                = var.enabled && var.enable_rai_blocklist ? 1 : 0
  name                 = var.resource_position_prefix ? format("crb-%s", local.name) : format("%s-crb", local.name)
  cognitive_account_id = azurerm_cognitive_account.main[0].id
  description          = var.rai_blocklist_description
}

resource "azurerm_cognitive_account_rai_policy" "main" {
  count                = var.enabled && var.enable_rai_policy ? 1 : 0
  name                 = var.resource_position_prefix ? format("raip-%s", local.name) : format("%s-raip", local.name)
  cognitive_account_id = azurerm_cognitive_account.main[0].id
  base_policy_name     = var.rai_policy_base_policy_name
  mode                 = var.rai_policy_mode
  tags                 = module.labels.tags

  dynamic "content_filter" {
    for_each = var.rai_policy_content_filters
    content {
      name               = content_filter.value.name
      filter_enabled     = content_filter.value.filter_enabled
      block_enabled      = content_filter.value.block_enabled
      severity_threshold = content_filter.value.severity_threshold
      source             = content_filter.value.source
    }
  }
}


##-----------------------------------------------------------------------------
## Private Endpoint
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "main" {
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = var.resource_position_prefix ? format("pe-%s", azurerm_cognitive_account.main[0].name) : format("%s-pe", azurerm_cognitive_account.main[0].name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = module.labels.tags

  private_service_connection {
    name                           = var.resource_position_prefix ? format("psc-%s", local.name) : format("%s-psc", local.name)
    private_connection_resource_id = azurerm_cognitive_account.main[0].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = var.resource_position_prefix ? format("dzg-%s", local.name) : format("%s-dzg", local.name)
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  depends_on = [azurerm_cognitive_account.main]
}

##-----------------------------------------------------------------------------
## Diagnostic Settings — Azure Monitor for Cognitive Account
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "main" {
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = var.resource_position_prefix ? format("diag-%s", local.name) : format("%s-diag", local.name)
  target_resource_id             = azurerm_cognitive_account.main[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = length(var.log_category) > 0 ? var.log_category : var.log_category_group
    content {
      category       = length(var.log_category) > 0 ? enabled_log.value : null
      category_group = length(var.log_category) > 0 ? null : enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }

  depends_on = [azurerm_cognitive_account.main]
}
