provider "azurerm" {
  features {}
}

module "cognitive" {
  source = "../../"
}
