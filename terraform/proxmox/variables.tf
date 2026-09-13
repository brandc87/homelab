variable "pve_root_password" {
  type      = string
  sensitive = true
}

variable "pve_token_secret" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "eve_ng_iso_file_id" {
  type        = string
  description = "EVE-NG installation ISO uploaded to a Proxmox ISO datastore."
  default     = "local:iso/eve-ng.iso"
}
