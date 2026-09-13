terraform {
  required_version = ">= 1.8.0"

  required_providers {
    unifi = {
      source  = "ubiquiti-community/unifi"
      version = "~> 0.55.0"
    }
  }
}

provider "unifi" {
  api_url        = var.unifi_api_url
  username       = var.unifi_username
  password       = var.unifi_password
  site           = var.unifi_site
  allow_insecure = var.unifi_allow_insecure
}
