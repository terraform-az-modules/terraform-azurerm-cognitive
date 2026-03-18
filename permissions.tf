##-----------------------------------------------------------------------------
## User Assigned Identity
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "main" {
  count               = var.enabled && var.enable_customer_managed_key ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.resource_position_prefix ? format("foundry-mid-%s", local.name) : format("%s-foundry-mid", local.name)
  tags                = module.labels.tags
}

##-----------------------------------------------------------------------------
## Role Assignment for User Assigned Identity to access key vault for encryption and decryption operation
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "identity_assigned" {
  depends_on           = [azurerm_user_assigned_identity.main]
  count                = var.enabled && var.enable_customer_managed_key ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}