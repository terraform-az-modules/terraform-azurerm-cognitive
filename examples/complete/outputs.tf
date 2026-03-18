##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "cognitive_account_id" {
  description = "The ID of the Cognitive Service Account"
  value       = module.openai_cognitive_service.cognitive_account_id
}

output "cognitive_account_endpoint" {
  description = "The endpoint URL used to connect to the Cognitive Service Account"
  value       = module.openai_cognitive_service.cognitive_account_endpoint
}

output "cognitive_account_primary_access_key" {
  description = "The primary access key for the Cognitive Service Account (only available when local_auth_enabled is true)"
  value       = module.openai_cognitive_service.cognitive_account_primary_access_key
  sensitive   = true
}

output "cognitive_account_secondary_access_key" {
  description = "The secondary access key for the Cognitive Service Account (only available when local_auth_enabled is true)"
  value       = module.openai_cognitive_service.cognitive_account_secondary_access_key
  sensitive   = true
}

output "private_endpoint_id" {
  description = "The ID of the Private Endpoint"
  value       = module.openai_cognitive_service.private_endpoint_id
}

output "private_endpoint_ip" {
  description = "The private IP address of the Private Endpoint NIC"
  value       = module.openai_cognitive_service.private_endpoint_ip
}

output "rai_blocklist_id" {
  description = "The ID of the Cognitive Account RAI Blocklist"
  value       = module.openai_cognitive_service.rai_blocklist_id
}

output "rai_policy_id" {
  description = "The ID of the Cognitive Service Account RAI Policy"
  value       = module.openai_cognitive_service.rai_policy_id
}
