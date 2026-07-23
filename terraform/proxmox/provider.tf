terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://10.15.1.10:8006/"
  api_token = "terraform@pve!tf=${var.pve_token_secret}"
  insecure  = true
}
