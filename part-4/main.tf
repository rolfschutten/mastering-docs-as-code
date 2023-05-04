data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "docusaurus" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_static_site" "docusaurus" {
  name                = var.app_name
  location            = azurerm_resource_group.docusaurus.location
  resource_group_name = azurerm_resource_group.docusaurus.name
}

resource "azurerm_cdn_profile" "docusaurus" {
  name                = var.cdn_profile_name
  location            = azurerm_resource_group.docusaurus.location
  resource_group_name = azurerm_resource_group.docusaurus.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "docusaurus" {
  name                = var.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.docusaurus.name
  location            = azurerm_resource_group.docusaurus.location
  resource_group_name = azurerm_resource_group.docusaurus.name
  origin_host_header  = azurerm_static_site.docusaurus.default_host_name
  
  origin {
    name                = var.app_name
    host_name           = azurerm_static_site.docusaurus.default_host_name    
  }
 
  delivery_rule {
    name = "HttpsRedirect"
    order = 1
    
    request_scheme_condition  {
      match_values = ["HTTP"]
      operator = "Equal"
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol = "Https"
    }
  }
}

resource "azurerm_cdn_endpoint_custom_domain" "docusaurus" {
  name            = var.custom_domain_name
  cdn_endpoint_id = azurerm_cdn_endpoint.docusaurus.id
  host_name       = var.custom_domain_host_name

  user_managed_https {
    key_vault_certificate_id     = azurerm_key_vault_certificate.docusaurus.id
  }
}

resource "azurerm_dns_zone" "docusaurus" {
  name                = var.custom_domain_host_name
  resource_group_name = azurerm_resource_group.docusaurus.name
}

resource "azurerm_dns_a_record" "docusaurus" {
  name                = "@"
  zone_name           = azurerm_dns_zone.docusaurus.name
  resource_group_name = azurerm_resource_group.docusaurus.name
  ttl                 = 60
  target_resource_id  = azurerm_cdn_endpoint.docusaurus.id
}

resource "azurerm_dns_cname_record" "docusaurus" {
  name                = "*"
  zone_name           = azurerm_dns_zone.docusaurus.name
  resource_group_name = azurerm_resource_group.docusaurus.name
  ttl                 = 60
  target_resource_id  = azurerm_cdn_endpoint.docusaurus.id
}

resource "azurerm_dns_cname_record" "SSL" {
  name                = var.ssl_validation_name
  zone_name           = azurerm_dns_zone.docusaurus.name
  resource_group_name = azurerm_resource_group.docusaurus.name
  ttl                 = 60
  record              = var.ssl_validation_record
}

resource "azurerm_dns_cname_record" "cdnverify" {
  name                = "cdnverify"
  zone_name           = azurerm_dns_zone.docusaurus.name
  resource_group_name = azurerm_resource_group.docusaurus.name
  ttl                 = 60
  record              = "cdnverify.${azurerm_cdn_endpoint.docusaurus.fqdn}"
}

resource "azurerm_key_vault" "docusaurus" {
  name                        = var.keyvault_name
  location                    = azurerm_resource_group.docusaurus.location
  resource_group_name         = azurerm_resource_group.docusaurus.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "github" {
  key_vault_id = azurerm_key_vault.docusaurus.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update",
  ]

  key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy",
  ]

  secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set",
  ]

  storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update",
  ]
}

resource "azurerm_key_vault_access_policy" "cdn" {
  key_vault_id = azurerm_key_vault.docusaurus.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.AzureFrontDoorCdn_ID

  certificate_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_certificate" "docusaurus" {
  name         = var.certificate_name
  key_vault_id = azurerm_key_vault.docusaurus.id

  certificate {
    contents = filebase64("certificate.pfx")
    password = var.certificate_password
  }
}
