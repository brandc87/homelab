variable "unifi_api_url" {
  type        = string
  description = "Local URL of the UniFi console."
  default     = "https://10.15.1.1"
}

variable "unifi_site" {
  type        = string
  description = "UniFi site name used by the Network application."
  default     = "default"
}

variable "unifi_allow_insecure" {
  type        = bool
  description = "Allow the UDM SE self-signed TLS certificate."
  default     = true
}

variable "unifi_username" {
  type        = string
  description = "Dedicated local UniFi automation account."
  sensitive   = true
}

variable "unifi_password" {
  type        = string
  description = "Password for the dedicated local UniFi automation account."
  sensitive   = true
}
