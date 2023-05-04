variable "resource_group_name" {
  type    = string
  default = ""
}

variable "app_name" {
  type    = string
  default = ""
}

variable "location" {
  type    = string
 default = ""
}

variable "cdn_profile_name" {
  type    = string
  default = ""
}

variable "cdn_endpoint_name" {
  type    = string
  default = ""
}

variable "custom_domain_name" {
  type    = string
  default = ""
}

variable "custom_domain_host_name" {
  type    = string
  default = ""
}

variable "ssl_validation_name" {
  type    = string
  default = ""
}

variable "ssl_validation_record" {
  type    = string
  default = ""
}

variable "keyvault_name" {
  type    = string
  default = ""
}

variable "AzureFrontDoorCdn_ID" {
  type    = string
  default = ""
}

variable "certificate_name" {
  type    = string
  default = ""
}

variable "certificate_password" {}
