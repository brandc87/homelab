output "id" {
  value = proxmox_virtual_environment_container.this.id
}

output "ip_address" {
  value = proxmox_virtual_environment_container.this.initialization[0].ip_config[0].ipv4[0].address
}
