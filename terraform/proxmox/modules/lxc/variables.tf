variable "hostname" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "ip_address" {
  type = string
}

variable "gateway" {
  type = string
}

variable "node_name" {
  type    = string
  default = "pve"
}

variable "cores" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 1024
}

variable "disk_size" {
  type    = number
  default = 8
}

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "vlan_id" {
  type    = number
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "ssh_public_key" {
  type = string
}

variable "template_file_id" {
  type    = string
  default = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
}

variable "mount_points" {
  type = list(object({
    volume = string
    path   = string
  }))
  default = []
}
