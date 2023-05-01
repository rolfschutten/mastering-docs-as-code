resource "azurerm_resource_group" "docusaurus" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_static_site" "docusaurus" {
  name                = var.app_name
  location            = azurerm_resource_group.docusaurus.location
  resource_group_name = azurerm_resource_group.docusaurus.name
}
