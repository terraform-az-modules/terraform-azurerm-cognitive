##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Define your custom name to override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "stor-core-dev".
- If false, the keyword is appended: "core-dev-stor".

This helps maintain naming consistency based on organizational preferences.
EOT
}


variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-cognitive.git"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg ''."
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

##-----------------------------------------------------------------------------
## Cognitive Account Variables
##-----------------------------------------------------------------------------
variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Cognitive Service Account is created. Changing this forces a new resource to be created."
}

variable "kind" {
  type        = string
  description = "Specifies the type of Cognitive Service Account. Possible values: AIServices, Academic, AnomalyDetector, Bing.Autosuggest, Bing.Autosuggest.v7, Bing.CustomSearch, Bing.Search, Bing.Search.v7, Bing.Speech, Bing.SpellCheck, Bing.SpellCheck.v7, CognitiveServices, ComputerVision, ContentModerator, ConversationalLanguageUnderstanding, ContentSafety, CustomSpeech, CustomVision.Prediction, CustomVision.Training, Emotion, Face, FormRecognizer, ImmersiveReader, LUIS, LUIS.Authoring, MetricsAdvisor, OpenAI, Personalizer, QnAMaker, Recommendations, SpeakerRecognition, Speech, SpeechServices, SpeechTranslation, TextAnalytics, TextTranslation and WebLM."
}

variable "sku_name" {
  type        = string
  description = "Specifies the SKU Name for this Cognitive Service Account. Possible values: C2, C3, C4, D3, DC0, E0, F0, F1, P0, P1, P2, S, S0, S1, S2, S3, S4, S5 and S6."
}

variable "custom_subdomain_name" {
  type        = string
  description = "The subdomain name used for Entra ID token-based authentication. Required when network_acls is specified. This can be specified during creation or added later, but once set changing this forces a new resource to be created."
  default     = null
}

variable "dynamic_throttling_enabled" {
  type        = bool
  description = "Whether to enable dynamic throttling for this Cognitive Service Account. Cannot be set when kind is OpenAI or AIServices."
  default     = false
}

variable "fqdns" {
  type        = list(string)
  description = "List of FQDNs allowed for the Cognitive Account."
  default     = []
}

variable "local_auth_enabled" {
  type        = bool
  description = "Whether local authentication methods is enabled for the Cognitive Account."
  default     = true
}

variable "metrics_advisor_aad_client_id" {
  type        = string
  description = "The Azure AD Client ID (Application ID). Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created."
  default     = null
}

variable "metrics_advisor_aad_tenant_id" {
  type        = string
  description = "The Azure AD Tenant ID. Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created."
  default     = null
}

variable "metrics_advisor_super_user_name" {
  type        = string
  description = "The super user of Metrics Advisor. Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created."
  default     = null
}

variable "metrics_advisor_website_name" {
  type        = string
  description = "The website name of Metrics Advisor. Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created."
  default     = null
}

variable "outbound_network_access_restricted" {
  type        = bool
  description = "Whether outbound network access is restricted for the Cognitive Account."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed for the Cognitive Account."
  default     = true
}

variable "qna_runtime_endpoint" {
  type        = string
  description = "A URL to link a QnAMaker cognitive account to a QnA runtime. Mandatory if kind is set to QnAMaker."
  default     = null
}

variable "custom_question_answering_search_service_id" {
  type        = string
  description = "If kind is TextAnalytics this specifies the ID of the Search service."
  default     = null
}

variable "custom_question_answering_search_service_key" {
  type        = string
  description = "If kind is TextAnalytics this specifies the key of the Search service."
  default     = null
  sensitive   = true
}

variable "project_management_enabled" {
  type        = bool
  description = "Whether project management is enabled when kind is set to AIServices. Once enabled, project_management_enabled cannot be disabled."
  default     = false
}

variable "network_acls" {
  type = object({
    default_action = string
    ip_rules       = optional(list(string), [])
    bypass         = optional(string)
    virtual_network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
  })
  description = <<EOT
Network ACL configuration for the Cognitive Account.
- default_action: Allow or Deny
- bypass: None or AzureServices (only valid for OpenAI, AIServices, TextAnalytics)
- ip_rules: List of IPs/ranges. Single IPs must be plain (e.g. "203.0.113.10") — /32 notation is NOT supported by Cognitive Services. Ranges use CIDR (e.g. "198.51.100.0/24").
- virtual_network_rules: List of subnet IDs. Subnet must have Microsoft.CognitiveServices service endpoint enabled.
EOT
  default     = null
}

variable "network_injection" {
  type = object({
    scenario  = string
    subnet_id = string
  })
  description = "Network injection configuration. Only applicable if kind is set to AIServices. Scenario must be 'agent'. The agent subnet must use an address space in the 172.* or 192.* ranges."
  default     = null
}

variable "storage" {
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  description = "Storage account configuration for certain cognitive services. Not all kinds support storage block (e.g., OpenAI does not support it)."
  default     = null
}

##-----------------------------------------------------------------------------
## Deployments Map
##-----------------------------------------------------------------------------
variable "deployments" {
  type = map(object({
    rai_policy_name        = optional(string, null)
    version_upgrade_option = optional(string, null)
    model = object({
      format  = string
      name    = string
      version = string
    })
    sku = object({
      name     = string
      capacity = optional(number, 1)
    })
  }))
  description = <<EOT
Map of model deployments. Key is used as the deployment identifier in the resource name.
Each deployment requires a model (format, name, version) and sku (name, capacity).
- rai_policy_name: Optional RAI policy. Defaults to Microsoft.DefaultV2 if null.
- version_upgrade_option: OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, NoAutoUpgrade.
- sku.name: GlobalStandard (recommended), Standard (regional, retiring), ProvisionedManaged.
- sku.capacity: Tokens per minute in thousands (1 = 1K TPM).
EOT
  default     = {}
}

##-----------------------------------------------------------------------------
## Projects Map
##-----------------------------------------------------------------------------
variable "projects" {
  type = map(object({
    display_name = string
    description  = optional(string, "")
    location     = optional(string, null)
    tags         = optional(map(string), {})
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }), null)
  }))
  description = <<EOT
Map of Foundry projects. Key is used as the project identifier in the resource name.
Each project requires a display_name. Identity defaults to SystemAssigned when not set.
project_management_enabled must be true on the cognitive account for projects to work.
EOT
  default     = {}
}

##-----------------------------------------------------------------------------
## Key Vault Key Variables
##-----------------------------------------------------------------------------
variable "enable_customer_managed_key" {
  type        = bool
  description = "Enable Customer Managed Key for Cognitive Account."
  default     = false
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault where the key will be created."
  default     = null
}

variable "key_type" {
  type        = string
  description = "Specifies the Key Type. Possible values: EC, EC-HSM, RSA, RSA-HSM."
  default     = "RSA"
}

variable "key_size" {
  type        = number
  description = "Specifies the Size of the RSA key. Possible values: 2048, 3072, 4096."
  default     = 2048
}

variable "key_opts" {
  type        = list(string)
  description = "A list of key operations. Possible values: decrypt, encrypt, sign, unwrapKey, verify, wrapKey."
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

##-----------------------------------------------------------------------------
## RAI Blocklist Variables
##-----------------------------------------------------------------------------
variable "enable_rai_blocklist" {
  type        = bool
  description = "Enable RAI Blocklist."
  default     = false
}

variable "rai_blocklist_description" {
  type        = string
  description = "Description of the RAI Blocklist."
  default     = "Azure OpenAI Rai Blocklist"
}

##-----------------------------------------------------------------------------
## RAI Policy Variables
##-----------------------------------------------------------------------------
variable "enable_rai_policy" {
  type        = bool
  description = "Enable RAI Policy."
  default     = false
}

variable "rai_policy_base_policy_name" {
  type        = string
  description = "The base policy name. Common: Microsoft.Default"
  default     = "Microsoft.Default"
}

variable "rai_policy_mode" {
  type        = string
  description = "Rai policy mode. Possible values: Default, Deferred, Blocking, Asynchronous_filter. Use Asynchronous_filter for API version 2024-10-01+."
  default     = "Default"
  validation {
    condition     = contains(["Default", "Deferred", "Blocking", "Asynchronous_filter"], var.rai_policy_mode)
    error_message = "Valid values for rai_policy_mode are: Default, Deferred, Blocking, Asynchronous_filter."
  }
}

variable "rai_policy_content_filters" {
  type = list(object({
    name               = string
    filter_enabled     = bool
    block_enabled      = bool
    severity_threshold = string
    source             = string
  }))
  description = "List of content filters. Name: Hate, Sexual, Violence, SelfHarm, Jailbreak, Indirect Attack, Protected Material Text, Protected Material Code. Severity: Low, Medium, High. Source: Prompt, Completion."
  default = [
    {
      name               = "Hate"
      filter_enabled     = true
      block_enabled      = true
      severity_threshold = "High"
      source             = "Prompt"
    }
  ]
}

##-----------------------------------------------------------------------------
## Private Endpoint Variables
##-----------------------------------------------------------------------------
variable "enable_private_endpoint" {
  type        = bool
  description = "Enable Private Endpoint for the Cognitive Account. Requires custom_subdomain_name to be set."
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The Subnet ID where the Private Endpoint will be created."
  default     = null
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "List of Private DNS Zone IDs to associate with the private endpoint. Typically: privatelink.cognitiveservices.azure.com or privatelink.openai.azure.com"
  default     = null
}

##----------------------------------------------------------------------------- 
## CMK Variables
##-----------------------------------------------------------------------------
variable "key_expiration_date" {
  type        = string
  description = "Expiration UTC datetime for the Key Vault key. Format: 2028-12-31T23:59:59Z. Set null for no expiry."
  default     = null
}

variable "rotation_policy_config" {
  type = object({
    enabled              = bool
    time_before_expiry   = optional(string, "P30D")
    expire_after         = optional(string, "P90D")
    notify_before_expiry = optional(string, "P29D")
  })
  description = <<EOT
Key rotation policy configuration.
- expire_after: Key lifetime in ISO 8601 (P1Y = 1 year, P90D = 90 days)
- time_before_expiry: Auto-rotate this long before expiry (P30D)
- notify_before_expiry: Must be less than time_before_expiry (P29D)
EOT
  default = {
    enabled              = false
    time_before_expiry   = "P30D"
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

##-----------------------------------------------------------------------------
## Diagnostic Settings Variables
##-----------------------------------------------------------------------------
variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Flag to control creation of diagnostic settings for the Cognitive Account."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics Workspace ID where logs should be sent."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "Destination type for Log Analytics. Possible values: AzureDiagnostics, Dedicated. Dedicated sends logs to resource-specific tables instead of the legacy AzureDiagnostics table."
  validation {
    condition     = contains(["AzureDiagnostics", "Dedicated"], var.log_analytics_destination_type)
    error_message = "Valid values are AzureDiagnostics or Dedicated."
  }
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Whether AllMetrics should be enabled in diagnostic settings."
}

variable "log_category" {
  type        = list(string)
  default     = []
  description = <<EOT
Specific log categories to enable. When set, takes priority over log_category_group.
Accepted values for Cognitive/AIServices:
- Audit
- RequestResponse
- Trace
EOT
}

variable "log_category_group" {
  type        = list(string)
  default     = ["audit"]
  description = "Log category group for diagnostic settings. Used when log_category is empty. Common values: audit, allLogs."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage Account ID to archive diagnostic logs."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Event Hub name to stream diagnostic logs to."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Event Hub authorization rule ID for streaming diagnostic logs."
}
