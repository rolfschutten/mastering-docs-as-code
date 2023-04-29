terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.54.0"
    }
  }
  backend "azurerm" {
        resource_group_name  = ""
        storage_account_name = ""
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
  }
}
provider "azurerm" { 
  features {}
}
