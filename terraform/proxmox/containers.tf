locals {
  # Containers using standard token-auth provider (no bind mounts)
  containers = {
    monitoring = {
      vm_id      = 303
      ip_address = "10.15.30.52"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 2048
      disk_size  = 16
      tags       = ["monitoring"]
    }
    amp-bot = {
      vm_id      = 304
      ip_address = "10.15.30.53"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 1
      memory     = 512
      disk_size  = 4
      tags       = ["discord-bot"]
    }
  }

  # Containers needing bind mounts (require root@pam auth)
  containers_with_mounts = {
    sonarr-anime = {
      vm_id      = 103
      ip_address = "10.15.30.13"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 1024
      disk_size  = 4
      tags       = ["arr"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" }
      ]
    }
    qbittorrent = {
      vm_id      = 109
      ip_address = "10.15.30.19"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 2048
      disk_size  = 8
      tags       = ["arr", "downloader"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" }
      ]
    }
  }
}

module "lxc" {
  for_each = local.containers
  source   = "./modules/lxc"

  providers = {
    proxmox = proxmox
  }

  hostname       = each.key
  vm_id          = each.value.vm_id
  ip_address     = each.value.ip_address
  gateway        = each.value.gateway
  vlan_id        = each.value.vlan_id
  cores          = each.value.cores
  memory         = each.value.memory
  disk_size      = each.value.disk_size
  tags           = each.value.tags
  ssh_public_key = var.ssh_public_key
}

module "lxc_mounted" {
  for_each = local.containers_with_mounts
  source   = "./modules/lxc"

  providers = {
    proxmox = proxmox.pam_auth
  }

  hostname       = each.key
  vm_id          = each.value.vm_id
  ip_address     = each.value.ip_address
  gateway        = each.value.gateway
  vlan_id        = each.value.vlan_id
  cores          = each.value.cores
  memory         = each.value.memory
  disk_size      = each.value.disk_size
  tags           = each.value.tags
  mount_points   = each.value.mount_points
  ssh_public_key = var.ssh_public_key
}
