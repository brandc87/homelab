locals {
  # Containers using standard token-auth provider (no bind mounts)
  containers = {
    beszel = {
      vm_id      = 150
      ip_address = "10.15.1.13"
      gateway    = "10.15.1.1"
      vlan_id    = null
      cores      = 1
      memory     = 512
      disk_size  = 8
      tags       = ["observability"]
      nesting    = true
    }
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
    tautulli = {
      vm_id      = 207
      ip_address = "10.15.30.18"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 1
      memory     = 512
      disk_size  = 8
      tags       = ["media", "observability"]
      nesting    = true
    }
    prowlarr = {
      vm_id      = 204
      ip_address = "10.15.30.14"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 1024
      disk_size  = 4
      tags       = ["arr", "indexer"]
      nesting    = true
    }
    notifiarr = {
      vm_id      = 205
      ip_address = "10.15.30.15"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 1
      memory     = 512
      disk_size  = 2
      tags       = ["media", "automation"]
      nesting    = true
    }
    seerr = {
      vm_id      = 206
      ip_address = "10.15.30.16"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 4
      memory     = 4096
      disk_size  = 12
      tags       = ["media", "requests"]
      nesting    = true
    }
  }

  # Containers needing bind mounts (require root@pam auth)
  containers_with_mounts = {
    radarr01 = {
      vm_id      = 200
      ip_address = "10.15.30.10"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 1024
      disk_size  = 4
      tags       = ["arr", "movies"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/media_root", path = "/mnt/fast_media_root" }
      ]
    }
    radarr02 = {
      vm_id      = 201
      ip_address = "10.15.30.11"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 1024
      disk_size  = 4
      tags       = ["arr", "movies"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/media_root", path = "/mnt/fast_media_root" }
      ]
    }
    sonarr01 = {
      vm_id      = 202
      ip_address = "10.15.30.12"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 1024
      disk_size  = 4
      tags       = ["arr", "tv"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/media_root", path = "/mnt/fast_media_root" }
      ]
    }
    sonarr02 = {
      vm_id      = 203
      ip_address = "10.15.30.13"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 1024
      disk_size  = 4
      tags       = ["arr", "tv", "anime"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/media_root", path = "/mnt/fast_media_root" }
      ]
    }
    sabnzbd = {
      vm_id      = 250
      ip_address = "10.15.30.17"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 4
      memory     = 4096
      disk_size  = 5
      tags       = ["downloader", "usenet"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/media_root", path = "/mnt/fast_media_root" }
      ]
    }
    qbittorrent = {
      vm_id      = 251
      ip_address = "10.15.30.19"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 2048
      disk_size  = 8
      tags       = ["downloader", "torrent", "vpn"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/media_root", path = "/mnt/fast_media_root" }
      ]
      device_passthrough = [
        { path = "/dev/net/tun", gid = 0, mode = "0666" }
      ]
    }
    plex = {
      vm_id      = 270
      ip_address = "10.15.30.7"
      gateway    = "10.15.30.1"
      vlan_id    = 30
      cores      = 2
      memory     = 2048
      disk_size  = 20
      tags       = ["media", "plex"]
      mount_points = [
        { volume = "/tank/media_root", path = "/mnt/media_root" },
        { volume = "/fast_tank/temp", path = "/mnt/temp" }
      ]
      device_passthrough = [
        { path = "/dev/dri/card0", gid = 44, mode = "0660" },
        { path = "/dev/dri/renderD128", gid = 44, mode = "0660" }
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
  nesting        = try(each.value.nesting, true)
  ssh_public_key = var.ssh_public_key
}

module "lxc_mounted" {
  for_each = local.containers_with_mounts
  source   = "./modules/lxc"

  providers = {
    proxmox = proxmox.pam_auth
  }

  hostname           = each.key
  vm_id              = each.value.vm_id
  ip_address         = each.value.ip_address
  gateway            = each.value.gateway
  vlan_id            = each.value.vlan_id
  cores              = each.value.cores
  memory             = each.value.memory
  disk_size          = each.value.disk_size
  tags               = each.value.tags
  nesting            = try(each.value.nesting, true)
  mount_points       = each.value.mount_points
  device_passthrough = try(each.value.device_passthrough, [])
  ssh_public_key     = var.ssh_public_key
}
