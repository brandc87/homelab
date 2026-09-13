terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source                = "bpg/proxmox"
      version               = "~> 0.113"
      configuration_aliases = [proxmox]
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = var.description
  node_name   = var.node_name
  vm_id       = var.vm_id
  tags        = var.tags

  started         = var.started
  on_boot         = var.on_boot
  stop_on_destroy = true

  machine = var.machine
  operating_system {
    type = "l26"
  }

  agent {
    enabled = var.agent_enabled
  }

  cpu {
    cores   = var.cores
    sockets = 1
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory
    floating  = 0
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  cdrom {
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  # Boot installation media when attached; Proxmox skips the empty drive after
  # iso_file_id is changed to "none" and then boots the installed SCSI disk.
  boot_order = ["ide2", "scsi0"]

  dynamic "network_device" {
    for_each = var.network_devices
    content {
      bridge  = network_device.value.bridge
      model   = network_device.value.model
      vlan_id = network_device.value.vlan_id
    }
  }

  vga {
    type = "std"
  }
}
