# EVE-NG

OpenTofu manages the EVE-NG VM hardware. EVE-NG remains responsible for its
guest operating system, network images, labs, and upgrades; it is deliberately
not included in the general Ansible bootstrap.

## Network prerequisites

Create these UniFi networks before installing EVE-NG:

| Network | VLAN | Subnet | Purpose |
| --- | ---: | --- | --- |
| EVE-MGMT | 70 | `10.15.70.0/24` | EVE web and SSH management |
| EVE-LAB | 71 | `10.15.71.0/24` | Isolated lab transit/Cloud1 |

The UniFi switch port facing Proxmox and Proxmox `vmbr0` must carry VLANs 70
and 71 as tagged networks. Do not trunk production VLANs into EVE-NG.

Use `10.15.70.10/24`, gateway `10.15.70.1`, for EVE-NG management. Add UniFi
zone policies that allow only trusted administration devices to EVE-MGMT and
EVE-LAB, block Lab-to-Internal initiation, and optionally allow Lab-to-Internet.

## Installation

1. Download the supported EVE-NG Freemium ISO from the official EVE-NG site.
2. Verify the published SHA-256 checksum.
3. Rename the verified file to `eve-ng.iso` and upload it to Proxmox storage
   `local` as ISO content.
4. Review and apply only the EVE-NG module first:

   ```bash
   tofu plan -target=module.eve_ng
   tofu apply -target=module.eve_ng
   ```

5. Open the Proxmox console for VM 501 and complete the EVE-NG installer.
6. Configure EVE management as `10.15.70.10/24` with gateway `10.15.70.1`.

The first VM NIC is EVE management (`pnet0`). The second VM NIC is VLAN 71 and
is available to labs as `Cloud1`/`pnet1`.

After installation, detach the ISO declaratively by setting this in
`terraform.tfvars` and applying again:

```hcl
eve_ng_iso_file_id = "none"
```

Vendor network images are not downloaded by this repository. Obtain them from
the vendor under the appropriate license and follow EVE-NG's image naming and
permissions documentation.
