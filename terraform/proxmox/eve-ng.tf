module "eve_ng" {
  source = "./modules/iso_vm"

  providers = {
    proxmox = proxmox
  }

  name        = "eve-ng"
  description = "EVE-NG network emulation lab"
  node_name   = "pve"
  vm_id       = 501
  tags        = ["appliance", "lab", "networking"]

  # The host has four physical cores/eight threads. Six vCPUs leaves capacity
  # for Proxmox and the always-on services while supporting several small nodes.
  cores         = 6
  memory        = 16384
  disk_size     = 200
  datastore_id  = "fast_tank"
  iso_file_id   = var.eve_ng_iso_file_id
  cpu_type      = "host"
  agent_enabled = false

  network_devices = [
    # EVE web/SSH management. Do not connect lab appliances to this network.
    { bridge = "vmbr0", model = "virtio", vlan_id = 70 },
    # Isolated external/transit network exposed to EVE as Cloud1/pnet1.
    { bridge = "vmbr0", model = "virtio", vlan_id = 71 }
  ]
}
