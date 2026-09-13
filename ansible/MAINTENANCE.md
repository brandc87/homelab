# Maintenance

Run commands from the `ansible` directory.

## Automatic security updates

The `bootstrap` role enables Debian security updates and does not permit an
automatic reboot. Apply only the baseline with:

```bash
ansible-playbook playbooks/bootstrap.yml
```

## Full convergence

Install the baseline and converge every managed service with:

```bash
ansible-playbook playbooks/site.yml
```

Use an inventory limit to converge one host or group without running unrelated
services:

```bash
ansible-playbook playbooks/site.yml --limit qbittorrent
ansible-playbook playbooks/site.yml --limit arr
```

## Routine maintenance

Update DNS nodes secondary-first, update the remaining LXCs one at a time, and
then update supported application services:

```bash
ansible-playbook playbooks/maintenance.yml
```

Reboots are disabled by default. To reboot hosts where the package manager says
one is required:

```bash
ansible-playbook playbooks/maintenance.yml -e system_update_reboot=true
```

## Targeted maintenance

```bash
# Cluster-aware Technitium OS and service update
ansible-playbook playbooks/maintenance-dns.yml

# LXC operating systems, excluding the DNS cluster
ansible-playbook playbooks/maintenance-lxcs.yml

# Supported services without a full OS upgrade
ansible-playbook playbooks/maintenance-services.yml

# Proxmox packages; never included in routine maintenance
ansible-playbook playbooks/maintenance-proxmox.yml
```

Review Proxmox updates before running its playbook. Reboot Proxmox only during a
planned maintenance window by adding `-e system_update_reboot=true`.

## Adding an application

Every application role should provide:

- `tasks/main.yml` for installation and desired configuration.
- `tasks/update.yml` for a deliberate application upgrade.
- A post-update health check before the next host is changed.

Add the application's inventory group to `playbooks/maintenance-services.yml`.
Use `serial: 1` for redundant or user-facing services.
