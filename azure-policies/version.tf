terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.80.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    
  }
  skip_provider_registration = "true"
}