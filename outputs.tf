##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "cognitive_account_id" {
  description = "The ID of the Cognitive Service Account"
  value       = try(azurerm_cognitive_account.main[0].id, null)
}

output "cognitive_account_endpoint" {
  description = "The endpoint URL used to connect to the Cognitive Service Account"
  value       = try(azurerm_cognitive_account.main[0].endpoint, null)
}

output "cognitive_account_primary_access_key" {
  description = "The primary access key for the Cognitive Service Account (only available when local_auth_enabled is true)"
  value       = try(azurerm_cognitive_account.main[0].primary_access_key, null)
  sensitive   = true
}

output "cognitive_account_secondary_access_key" {
  description = "The secondary access key for the Cognitive Service Account (only available when local_auth_enabled is true)"
  value       = try(azurerm_cognitive_account.main[0].secondary_access_key, null)
  sensitive   = true
}

output "private_endpoint_id" {
  description = "The ID of the Private Endpoint"
  value       = try(azurerm_private_endpoint.main[0].id, null)
}

output "private_endpoint_ip" {
  description = "The private IP address of the Private Endpoint NIC"
  value       = try(azurerm_private_endpoint.main[0].private_service_connection[0].private_ip_address, null)
}

output "rai_policy_id" {
  description = "The ID of the RAI Policy"
  value       = try(azurerm_cognitive_account_rai_policy.main[0].id, null)
}

output "rai_blocklist_id" {
  description = "The ID of the RAI Blocklist"
  value       = try(azurerm_cognitive_account_rai_blocklist.main[0].id, null)
}

output "diagnostic_setting_id" {
  description = "The ID of the Diagnostic Setting"
  value       = try(azurerm_monitor_diagnostic_setting.main[0].id, null)
}

output "deployment_ids" {
  description = "Map of deployment key to deployment resource ID"
  value       = { for k, v in azurerm_cognitive_deployment.main : k => v.id }
}

output "deployment_names" {
  description = "Map of deployment key to actual deployment name in Azure"
  value       = { for k, v in azurerm_cognitive_deployment.main : k => v.name }
}

output "project_ids" {
  description = "Map of project key to project resource ID"
  value       = { for k, v in azurerm_cognitive_account_project.main : k => v.id }
}
