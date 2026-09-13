variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "Managed by OpenTofu"
}

variable "node_name" {
  type    = string
  default = "pve"
}

variable "vm_id" {
  type = number
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "datastore_id" {
  type = string
}

variable "iso_file_id" {
  type        = string
  description = "Proxmox ISO file ID, or 'none' after installation media is detached."
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "machine" {
  type    = string
  default = "q35"
}

variable "agent_enabled" {
  type    = bool
  default = false
}

variable "started" {
  type    = bool
  default = true
}

variable "on_boot" {
  type    = bool
  default = true
}

variable "network_devices" {
  type = list(object({
    bridge  = optional(string, "vmbr0")
    model   = optional(string, "virtio")
    vlan_id = optional(number)
  }))
}
