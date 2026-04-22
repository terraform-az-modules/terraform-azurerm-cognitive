## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| custom\_name | Define your custom name to override default naming convention | `string` | `null` | no |
| custom\_question\_answering\_search\_service\_id | If kind is TextAnalytics this specifies the ID of the Search service. | `string` | `null` | no |
| custom\_question\_answering\_search\_service\_key | If kind is TextAnalytics this specifies the key of the Search service. | `string` | `null` | no |
| custom\_subdomain\_name | The subdomain name used for Entra ID token-based authentication. Required when network\_acls is specified. This can be specified during creation or added later, but once set changing this forces a new resource to be created. | `string` | `null` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| deployments | Map of model deployments. Key is used as the deployment identifier in the resource name.<br>Each deployment requires a model (format, name, version) and sku (name, capacity).<br>- rai\_policy\_name: Optional RAI policy. Defaults to Microsoft.DefaultV2 if null.<br>- version\_upgrade\_option: OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, NoAutoUpgrade.<br>- sku.name: GlobalStandard (recommended), Standard (regional, retiring), ProvisionedManaged.<br>- sku.capacity: Tokens per minute in thousands (1 = 1K TPM). | <pre>map(object({<br>    rai_policy_name        = optional(string, null)<br>    version_upgrade_option = optional(string, null)<br>    model = object({<br>      format  = string<br>      name    = string<br>      version = string<br>    })<br>    sku = object({<br>      name     = string<br>      capacity = optional(number, 1)<br>    })<br>  }))</pre> | `{}` | no |
| dynamic\_throttling\_enabled | Whether to enable dynamic throttling for this Cognitive Service Account. Cannot be set when kind is OpenAI or AIServices. | `bool` | `false` | no |
| enable\_customer\_managed\_key | Enable Customer Managed Key for Cognitive Account. | `bool` | `false` | no |
| enable\_diagnostic | Flag to control creation of diagnostic settings for the Cognitive Account. | `bool` | `false` | no |
| enable\_private\_endpoint | Enable Private Endpoint for the Cognitive Account. Requires custom\_subdomain\_name to be set. | `bool` | `false` | no |
| enable\_rai\_blocklist | Enable RAI Blocklist. | `bool` | `false` | no |
| enable\_rai\_policy | Enable RAI Policy. | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Event Hub authorization rule ID for streaming diagnostic logs. | `string` | `null` | no |
| eventhub\_name | Event Hub name to stream diagnostic logs to. | `string` | `null` | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| fqdns | List of FQDNs allowed for the Cognitive Account. | `list(string)` | `[]` | no |
| key\_expiration\_date | Expiration UTC datetime for the Key Vault key. Format: 2028-12-31T23:59:59Z. Set null for no expiry. | `string` | `null` | no |
| key\_opts | A list of key operations. Possible values: decrypt, encrypt, sign, unwrapKey, verify, wrapKey. | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| key\_size | Specifies the Size of the RSA key. Possible values: 2048, 3072, 4096. | `number` | `2048` | no |
| key\_type | Specifies the Key Type. Possible values: EC, EC-HSM, RSA, RSA-HSM. | `string` | `"RSA"` | no |
| key\_vault\_id | The ID of the Key Vault where the key will be created. | `string` | `null` | no |
| kind | Specifies the type of Cognitive Service Account. Possible values: AIServices, Academic, AnomalyDetector, Bing.Autosuggest, Bing.Autosuggest.v7, Bing.CustomSearch, Bing.Search, Bing.Search.v7, Bing.Speech, Bing.SpellCheck, Bing.SpellCheck.v7, CognitiveServices, ComputerVision, ContentModerator, ConversationalLanguageUnderstanding, ContentSafety, CustomSpeech, CustomVision.Prediction, CustomVision.Training, Emotion, Face, FormRecognizer, ImmersiveReader, LUIS, LUIS.Authoring, MetricsAdvisor, OpenAI, Personalizer, QnAMaker, Recommendations, SpeakerRecognition, Speech, SpeechServices, SpeechTranslation, TextAnalytics, TextTranslation and WebLM. | `string` | n/a | yes |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| local\_auth\_enabled | Whether local authentication methods is enabled for the Cognitive Account. | `bool` | `true` | no |
| location | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| log\_analytics\_destination\_type | Destination type for Log Analytics. Possible values: AzureDiagnostics, Dedicated. Dedicated sends logs to resource-specific tables instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| log\_analytics\_workspace\_id | Log Analytics Workspace ID where logs should be sent. | `string` | `null` | no |
| log\_category | Specific log categories to enable. When set, takes priority over log\_category\_group.<br>Accepted values for Cognitive/AIServices:<br>- Audit<br>- RequestResponse<br>- Trace | `list(string)` | `[]` | no |
| log\_category\_group | Log category group for diagnostic settings. Used when log\_category is empty. Common values: audit, allLogs. | `list(string)` | <pre>[<br>  "audit"<br>]</pre> | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| metric\_enabled | Whether AllMetrics should be enabled in diagnostic settings. | `bool` | `true` | no |
| metrics\_advisor\_aad\_client\_id | The Azure AD Client ID (Application ID). Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created. | `string` | `null` | no |
| metrics\_advisor\_aad\_tenant\_id | The Azure AD Tenant ID. Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created. | `string` | `null` | no |
| metrics\_advisor\_super\_user\_name | The super user of Metrics Advisor. Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created. | `string` | `null` | no |
| metrics\_advisor\_website\_name | The website name of Metrics Advisor. Only set when kind is MetricsAdvisor. Changing this forces a new resource to be created. | `string` | `null` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_acls | Network ACL configuration for the Cognitive Account.<br>- default\_action: Allow or Deny<br>- bypass: None or AzureServices (only valid for OpenAI, AIServices, TextAnalytics)<br>- ip\_rules: List of IPs/ranges. Single IPs must be plain (e.g. "203.0.113.10") — /32 notation is NOT supported by Cognitive Services. Ranges use CIDR (e.g. "198.51.100.0/24").<br>- virtual\_network\_rules: List of subnet IDs. Subnet must have Microsoft.CognitiveServices service endpoint enabled. | <pre>object({<br>    default_action = string<br>    ip_rules       = optional(list(string), [])<br>    bypass         = optional(string)<br>    virtual_network_rules = optional(list(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br>    })), [])<br>  })</pre> | `null` | no |
| network\_injection | Network injection configuration. Only applicable if kind is set to AIServices. Scenario must be 'agent'. The agent subnet must use an address space in the 172.\* or 192.\* ranges. | <pre>object({<br>    scenario  = string<br>    subnet_id = string<br>  })</pre> | `null` | no |
| outbound\_network\_access\_restricted | Whether outbound network access is restricted for the Cognitive Account. | `bool` | `false` | no |
| private\_dns\_zone\_ids | List of Private DNS Zone IDs to associate with the private endpoint. Typically: privatelink.cognitiveservices.azure.com or privatelink.openai.azure.com | `list(string)` | `null` | no |
| private\_endpoint\_subnet\_id | The Subnet ID where the Private Endpoint will be created. | `string` | `null` | no |
| project\_management\_enabled | Whether project management is enabled when kind is set to AIServices. Once enabled, project\_management\_enabled cannot be disabled. | `bool` | `false` | no |
| projects | Map of Foundry projects. Key is used as the project identifier in the resource name.<br>Each project requires a display\_name. Identity defaults to SystemAssigned when not set.<br>project\_management\_enabled must be true on the cognitive account for projects to work. | <pre>map(object({<br>    display_name = string<br>    description  = optional(string, "")<br>    location     = optional(string, null)<br>    tags         = optional(map(string), {})<br>    identity = optional(object({<br>      type         = string<br>      identity_ids = optional(list(string), [])<br>    }), null)<br>  }))</pre> | `{}` | no |
| public\_network\_access\_enabled | Whether public network access is allowed for the Cognitive Account. | `bool` | `true` | no |
| qna\_runtime\_endpoint | A URL to link a QnAMaker cognitive account to a QnA runtime. Mandatory if kind is set to QnAMaker. | `string` | `null` | no |
| rai\_blocklist\_description | Description of the RAI Blocklist. | `string` | `"Azure OpenAI Rai Blocklist"` | no |
| rai\_policy\_base\_policy\_name | The base policy name. Common: Microsoft.Default | `string` | `"Microsoft.Default"` | no |
| rai\_policy\_content\_filters | List of content filters. Name: Hate, Sexual, Violence, SelfHarm, Jailbreak, Indirect Attack, Protected Material Text, Protected Material Code. Severity: Low, Medium, High. Source: Prompt, Completion. | <pre>list(object({<br>    name               = string<br>    filter_enabled     = bool<br>    block_enabled      = bool<br>    severity_threshold = string<br>    source             = string<br>  }))</pre> | <pre>[<br>  {<br>    "block_enabled": true,<br>    "filter_enabled": true,<br>    "name": "Hate",<br>    "severity_threshold": "High",<br>    "source": "Prompt"<br>  }<br>]</pre> | no |
| rai\_policy\_mode | Rai policy mode. Possible values: Default, Deferred, Blocking, Asynchronous\_filter. Use Asynchronous\_filter for API version 2024-10-01+. | `string` | `"Default"` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azure-cognitive.git"` | no |
| resource\_group\_name | The name of the resource group in which the Cognitive Service Account is created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource\_position\_prefix | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>- If true, the keyword is prepended: "stor-core-dev".<br>- If false, the keyword is appended: "core-dev-stor".<br><br>This helps maintain naming consistency based on organizational preferences. | `bool` | `true` | no |
| rotation\_policy\_config | Key rotation policy configuration.<br>- expire\_after: Key lifetime in ISO 8601 (P1Y = 1 year, P90D = 90 days)<br>- time\_before\_expiry: Auto-rotate this long before expiry (P30D)<br>- notify\_before\_expiry: Must be less than time\_before\_expiry (P29D) | <pre>object({<br>    enabled              = bool<br>    time_before_expiry   = optional(string, "P30D")<br>    expire_after         = optional(string, "P90D")<br>    notify_before_expiry = optional(string, "P29D")<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "expire_after": "P90D",<br>  "notify_before_expiry": "P29D",<br>  "time_before_expiry": "P30D"<br>}</pre> | no |
| sku\_name | Specifies the SKU Name for this Cognitive Service Account. Possible values: C2, C3, C4, D3, DC0, E0, F0, F1, P0, P1, P2, S, S0, S1, S2, S3, S4, S5 and S6. | `string` | n/a | yes |
| storage | Storage account configuration for certain cognitive services. Not all kinds support storage block (e.g., OpenAI does not support it). | <pre>list(object({<br>    storage_account_id = string<br>    identity_client_id = optional(string)<br>  }))</pre> | `null` | no |
| storage\_account\_id | Storage Account ID to archive diagnostic logs. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cognitive\_account\_endpoint | The endpoint URL used to connect to the Cognitive Service Account |
| cognitive\_account\_id | The ID of the Cognitive Service Account |
| cognitive\_account\_primary\_access\_key | The primary access key for the Cognitive Service Account (only available when local\_auth\_enabled is true) |
| cognitive\_account\_secondary\_access\_key | The secondary access key for the Cognitive Service Account (only available when local\_auth\_enabled is true) |
| deployment\_ids | Map of deployment key to deployment resource ID |
| deployment\_names | Map of deployment key to actual deployment name in Azure |
| diagnostic\_setting\_id | The ID of the Diagnostic Setting |
| private\_endpoint\_id | The ID of the Private Endpoint |
| private\_endpoint\_ip | The private IP address of the Private Endpoint NIC |
| project\_ids | Map of project key to project resource ID |
| rai\_blocklist\_id | The ID of the RAI Blocklist |
| rai\_policy\_id | The ID of the RAI Policy |

