# Read-only adoption discovery. These data sources do not manage or alter the
# existing controller objects.
data "unifi_network" "management" {
  name = "Management"
}

data "unifi_network" "trusted" {
  name = "Trusted"
}

data "unifi_network" "secure" {
  name = "Secure"
}

data "unifi_network" "production" {
  name = "Production"
}

data "unifi_network" "dmz" {
  name = "DMZ"
}

output "existing_network_ids" {
  description = "Controller IDs used by the staged import process."
  value = {
    management = data.unifi_network.management.id
    trusted    = data.unifi_network.trusted.id
    secure     = data.unifi_network.secure.id
    production = data.unifi_network.production.id
    dmz        = data.unifi_network.dmz.id
  }
}
