# Proxmox VMID scheme

VMIDs are grouped by function. Existing resources outside these ranges are
moved when they are rebuilt rather than imported solely to renumber them.

| Range | Purpose | Examples |
| --- | --- | --- |
| 100-149 | Core infrastructure | Technitium DNS, Caddy |
| 150-179 | Observability | Beszel, monitoring |
| 180-199 | Automation and internal tools | amp-bot |
| 200-249 | Media management | Arr services, Seerr, Notifiarr, Tautulli |
| 250-269 | Download clients | SABnzbd, future qBittorrent |
| 270-299 | Media servers | Plex |
| 500-599 | Full VMs and appliances | 500 Home Assistant OS, 501 EVE-NG |
| 900-949 | Templates and test resources | Golden images and temporary builds |

## Media allocation

| VMID | Service |
| --- | --- |
| 200 | Radarr |
| 201 | Radarr 4K |
| 202 | Sonarr |
| 203 | Sonarr Anime |
| 204 | Prowlarr |
| 205 | Notifiarr |
| 206 | Seerr |
| 207 | Tautulli |

## Other planned allocations

| VMID | Service |
| --- | --- |
| 250 | SABnzbd |
| 270 | Plex |
| 500 | Home Assistant OS |
