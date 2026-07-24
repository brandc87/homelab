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

  ssh {
    agent    = true
    username = "root"
  }
}

# Second alias: authenticates as root@pam via password, required for
# any resource using a bind-mount mount_point (Proxmox restricts bind
# mounts to root@pam sessions; API tokens can never do this, by design).
provider "proxmox" {
  alias    = "pam_auth"
  endpoint = "https://10.15.1.10:8006/"
  username = "root@pam"
  password = var.pve_root_password
  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}
