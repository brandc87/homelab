resource "proxmox_virtual_environment_container" "qbittorrent" {
  provider     = proxmox.pam_auth
  node_name    = "pve"
  vm_id        = 109
  unprivileged = true
  tags         = ["downloader", "arr"]

  initialization {
    hostname = "qbittorrent"

    ip_config {
      ipv4 {
        address = "10.15.30.19/24"
        gateway = "10.15.30.1"
      }
    }

    user_account {
      keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEV6AjjRiEIjzcwvE1j7KZixRsNO1fvEHdwEaVvze99i"]
      password = null
    }
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  cpu { cores = 2 }
  memory { dedicated = 2048 }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  mount_point {
    volume = "/tank/media_root"
    path   = "/mnt/media_root"
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 30
  }

  features {
    nesting = true
  }
}
