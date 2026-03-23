##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Data Sources
##-----------------------------------------------------------------------------
data "azurerm_client_config" "current_client_config" {}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "core"
  environment = "uat"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

# ------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.4"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

# ------------------------------------------------------------------------------
# Subnet
# ------------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name              = "subnet1"
      subnet_prefixes   = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.CognitiveServices"]
    }
  ]
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "2.1.0"
  name                          = "core4"
  environment                   = "dev"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  enable_rbac_authorization     = true
  enable_private_endpoint       = false
  public_network_access_enabled = true
  enable_access_policies        = false
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  diagnostic_setting_enable = false
}

# ------------------------------------------------------------------------------
# Log Analytics
# ------------------------------------------------------------------------------
module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "1.0.2"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## Private DNS Zone module call
##-----------------------------------------------------------------------------
module "private_dns" {
  source              = "terraform-az-modules/private-dns/azurerm"
  version             = "1.0.5"
  name                = "core"
  environment         = "dev"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  private_dns_config = [
    {
      resource_type = "azure_ai_services"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

module "openai_cognitive_service" {
  source                     = "../.."
  name                       = "ai-service"
  environment                = "test"
  label_order                = ["name", "environment", "location"]
  resource_group_name        = module.resource_group.resource_group_name
  location                   = module.resource_group.resource_group_location
  sku_name                   = "S0"
  kind                       = "AIServices"
  project_management_enabled = true
  custom_subdomain_name      = "ai-service-test-002"
  enable_rai_policy          = false
  enable_rai_blocklist       = false

  ##---------------------------------------------------------------------------
  ## Multiple Model Deployments
  ##---------------------------------------------------------------------------
  deployments = {
    "gpt4o-mini" = {
      version_upgrade_option = "OnceCurrentVersionExpired"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o-mini"
        version = "2024-07-18"
      }
      sku = {
        name     = "GlobalStandard"
        capacity = 10
      }
    }
    "gpt5-mini" = {
      version_upgrade_option = "OnceCurrentVersionExpired"
      model = {
        format  = "OpenAI"
        name    = "gpt-5-mini" # ← model name
        version = "2025-08-07" # ← GA version
      }
      sku = {
        name     = "GlobalStandard"
        capacity = 10
      }
    }
  }

  ##---------------------------------------------------------------------------
  ## Multiple Foundry Projects
  ##---------------------------------------------------------------------------
  projects = {
    "mlops" = {
      display_name = "MLOps Project"
      description  = "CI/CD for AI models"
      tags         = { "team" = "platform" }
    }
    "chatbot" = {
      display_name = "Chatbot Project"
      description  = "Customer-facing GPT-4o chatbot"
      tags         = { "team" = "product" }
      identity = {
        type         = "SystemAssigned"
        identity_ids = []
      }
    }
  }

  ##---------------------------------------------------------------------------
  ## IP Firewall + VNet Rules
  ##---------------------------------------------------------------------------
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules = [
      "203.0.113.10",    # single IP must have /32
      "198.51.100.0/24", # range is fine with /24
    ]
    virtual_network_rules = [
      {
        subnet_id                            = module.subnet.subnet_ids["subnet1"]
        ignore_missing_vnet_service_endpoint = false
      },
    ]
  }

  ##---------------------------------------------------------------------------
  ## Private Endpoint
  ##---------------------------------------------------------------------------
  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.subnet.subnet_ids["subnet1"]
  private_dns_zone_ids       = [module.private_dns.private_dns_zone_ids["azure_ai_services"]]

  ##---------------------------------------------------------------------------
  ## Cmk
  ##---------------------------------------------------------------------------
  enable_customer_managed_key = true
  key_vault_id                = module.vault.id

  ##---------------------------------------------------------------------------
  ## Diagnostic Setting
  ##---------------------------------------------------------------------------
  enable_diagnostic          = true
  log_analytics_workspace_id = module.log-analytics.workspace_id

}
