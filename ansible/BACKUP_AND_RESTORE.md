# Application backup and restore

OpenTofu recreates guests and Ansible reinstalls applications. Application
state is handled separately so rebuilding a guest does not mean reconfiguring
the application.

## Sonarr recovery test

Create a consistent backup (Sonarr is stopped briefly while its SQLite data is
archived):

```bash
ansible-playbook playbooks/backup-services.yml --limit sonarr02
```

The controller stores the archive at
`backups/sonarr02/sonarr-latest.tar.gz`. Backups are deliberately ignored
by Git because they contain application secrets.

After OpenTofu recreates the LXC and `playbooks/sonarr.yml` installs Sonarr,
restore its state with:

```bash
ansible-playbook playbooks/restore-services.yml --limit sonarr02
```

The restore preserves the numeric owners recorded in the archive. The Sonarr
role therefore keeps its service identity stable at UID 1000 and GID 10000.

Media is not included in this archive. It remains on the Proxmox ZFS pool and
is exposed to the LXC through bind mounts.

This local archive is the first recovery target, not the final backup policy.
It should later be copied or written to storage outside the Proxmox host and
controller.

## Grouped Arr operations

Back up or restore every currently managed Arr service serially:

```bash
ansible-playbook playbooks/backup-services.yml --limit arr
ansible-playbook playbooks/restore-services.yml --limit arr
```

Use an inventory limit for one service:

```bash
ansible-playbook playbooks/backup-services.yml --limit prowlarr
ansible-playbook playbooks/restore-services.yml --limit prowlarr
```
