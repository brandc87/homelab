variable "pve_root_password" {
  type      = string
  sensitive = true
}

variable "pve_token_secret" {
  type      = string
  sensitive = true
}
