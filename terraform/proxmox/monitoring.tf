resource "proxmox_virtual_environment_container" "monitoring" {
  node_name = "pve"
  vm_id = 303
  unprivileged = true

  initialization {
    hostname = "monitoring"

    ip_config {
      ipv4 {
        address = "10.15.30.52/24"
        gateway = "10.15.30.1"
      }
    }

    user_account {
      keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEV6AjjRiEIjzcwvE1j7KZixRsNO1fvEHdwEaVvze99i"]
      password = null
    }
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type = "debian"
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    size = 16
  }

  network_interface {
    name = "eth0"
    bridge = "vmbr0"
    vlan_id = 30
  }

  features {
    nesting = true
  }
}

output "monitoring_ip" {
  value = proxmox_virtual_environment_container.monitoring.initialization[0].ip_config[0].ipv4[0].address
}
