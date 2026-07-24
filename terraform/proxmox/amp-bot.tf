resource "proxmox_virtual_environment_container" "amp-bot" {
  node_name    = "pve"
  vm_id        = 304
  unprivileged = true
  tags         = ["discord-bot"]

  initialization {
    hostname = "amp-bot"

    ip_config {
      ipv4 {
        address = "10.15.30.53/24"
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

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
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
