# Homelab

A self-hosted infrastructure project running on a repurposed HP Pavilion h8 tower. Built from the ground up: bare metal installation, ZFS storage, full VM/LXC provisioning via Terraform, and a complete self-hosted service stack covering media, communications, monitoring, and community infrastructure.

---

## Hardware

| Component      | Spec                                                  |
| -------------- | ----------------------------------------------------- |
| **Case**       | HP Pavilion h8 Tower                                  |
| **CPU**        | AMD FX-8350 Eight-Core @ 4.0GHz (AM3+, 125W TDP)      |
| **RAM**        | 32GB Timetec DDR3 1600MHz (4×8GB)                     |
| **Boot Drive** | Crucial BX500 240GB SATA SSD                          |
| **Storage**    | 12TB HGST Ultrastar HUH721212ALE601 (ZFS pool `tank`) |

> Planning upgrade to Ryzen 5600G + B550 Mini-ITX for proper IOMMU passthrough, DDR4, and lower power draw (~65W vs 125W TDP).

---

## Architecture

**Proxmox VE 9.1** runs bare metal on the SSD. Services are isolated in VMs and LXC containers provisioned via Terraform using the `bpg/proxmox` provider. Terraform remote state is stored in a MinIO S3 bucket on TrueNAS.

Network routing is handled by a **TP-Link ER707-M2** (gateway `10.0.0.2`) with Wi-Fi via TP-Link EAP670 AP (Omada stack). Dynamic DNS is kept current via a Cloudflare DDNS script. All external traffic terminates at the Nginx reverse proxy with Certbot-issued SSL per subdomain.

### VM / LXC Inventory

| VM ID | Role          | Type | OS            | Key Services                                             |
| ----- | ------------- | ---- | ------------- | ---------------------------------------------------------|
| 100   | NAS           | VM   | TrueNAS SCALE | ZFS pool `tank`, MinIO (S3 remote state), Syncthing       |
| 101   | Monitoring    | VM   | Ubuntu        | Prometheus, Grafana, alerting (SMTP)                     |
| 102   | Reverse Proxy | VM   | Debian        | Nginx, Certbot, SSL termination                          |
| 103   | Community     | VM   | Debian        | Stoat (self-hosted Revolt), Mumble, LiveKit               |
| 104   | Database      | LXC  | Debian        | PostgreSQL, PgBouncer, postgres_exporter                  |
| 105   | Wiki          | VM   | Debian        | DokuWiki (HyeTechWiki)                                    |
| 107   | Blog          | VM   | Debian        | Ghost (yeghiasargis.com)                                  |

---

## Decommissioned Infrastructure

A record of retired VMs/LXCs and why, kept for context on how the homelab has evolved.

| VM ID | Role                    | Reason                                                                                                   |
| ----- | ----------------------- | ---------------------------------------------------------------------------------------------------------|
| 104   | Game Server (open.mp)   | GTA:SA RPG server retired; data loss accepted. ID later reused for the PostgreSQL LXC.                   |
| 106   | E-Commerce (Nairi Café) | Medusa.js v2 storefront retired; data loss accepted. Business chose to use Shopify as a simpler alternative. |
| 108   | Git (Gitea)             | Compromised by an active cryptominer. Fully decommissioned rather than cleaned in place; replaced with Syncthing (VM 100) for notes/repo sync. |
| 109   | Game Server (Valheim)   | Dedicated Valheim server retired; data loss accepted. |

Retiring 104/106/108/109 also freed up enough headroom to right-size the remaining fleet: VM 101 (Monitoring) and VM 100 (TrueNAS) both had their core counts adjusted downward to better match actual load, reflected in the current Terraform config.

---

## Services

### Storage — TrueNAS SCALE (VM 100)

ZFS pool `tank` on the 12TB HDD, passed through via stable disk ID. Hosts MinIO for S3-compatible Terraform remote state, and is registered as NFS-backed storage in Proxmox for LXC storage-backed mount points (e.g. `truenas-pgdata`). Also runs Jellyfin, Calibre-Web (with Kobo Sage sync), Syncthing, Navidrome, Immich (12k+ photo assets), and Transmission.

### Monitoring — Ubuntu (VM 101)

Prometheus scrapes node-exporter from all VMs, plus postgres_exporter from the database LXC. Grafana dashboards provide full visibility across the stack. Alert rules configured for high disk (>90%), RAM (>95%), CPU (>95%), and host-down events, delivered via SMTP.

### Reverse Proxy — Debian (VM 102)

Nginx handles all inbound HTTPS traffic, routing by subdomain to internal services. SSL certificates issued per subdomain via Certbot against Cloudflare DNS.

### Community — Debian (VM 103)

**Stoat** (self-hosted [Revolt](https://revolt.chat)) at `chat.armstream.stream` — fully self-hosted chat platform. **LiveKit** provides voice/video (TCP 7881, UDP 50000–50100 forwarded at router). **Mumble** at `voice.armstream.stream:64738` for low-latency voice. Custom Python Mumble music bot ([mumblebot](https://github.com/yeghia-s/mumblebot)) using pymumble + yt-dlp + ffmpeg.

### Database — Debian 12 LXC (VM 104)

General-purpose PostgreSQL instance, provisioned as a lightweight LXC container rather than a full VM. Data directory is mounted from a TrueNAS-backed NFS storage pool (`truenas-pgdata`) rather than local disk, so container rebuilds don't threaten the data. **PgBouncer** sits in front for connection pooling across multiple apps, and **postgres_exporter** feeds the shared Prometheus/Grafana stack. One database + role per consuming application. Backed up via `pg_dumpall`/`pg_dump` on a cron timer, shipped to TrueNAS.

### Wiki — Debian (VM 105)

[HyeTechWiki](https://wiki.hyetechnology.org) — DokuWiki instance with Bootstrap3 theme. An Armenian-language technical wiki for Armenian developers in both the homeland and diaspora.

### Blog — Debian (VM 107)

Ghost instance at [yeghiasargis.com](https://yeghiasargis.com). Canonical home for the *Built and Written* weekly.

---

## Infrastructure as Code

All VMs and LXC containers are provisioned via **Terraform** using the `bpg/proxmox` provider. Remote state is stored in a **MinIO S3 bucket** on TrueNAS, keeping state off local disk and enabling consistent provisioning.

```
homelab/
└── terraform/
    ├── backend.tf        # MinIO S3 remote state config
    ├── providers.tf      # bpg/proxmox provider + SSH config
    ├── variables.tf      # proxmox_endpoint, proxmox_api_token, ssh_public_keys, etc.
    ├── terraform.tfvars   # actual values (gitignored)
    └── vms.tf            # VM/LXC resource definitions
```

**Notes on LXC storage-backed volumes:** Proxmox's API rejects raw bind-mount paths and, separately, has a known bug preventing API tokens (even root-issued ones) from allocating storage-backed `mount_point` volumes directly — both require `root@pam` session auth rather than a token. The `vms.tf` config works around this by provisioning the container's base config via the API token as usual, then attaching storage-backed mount points via a `null_resource` + `local-exec` SSH call authenticated with a key already trusted by the Proxmox host's `root` account (using the existing `ssh-agent`, no token escalation required).

---

## Networking

- **Router:** TP-Link ER707-M2 (gateway `10.0.0.2`)
- **Wi-Fi:** TP-Link EAP670 AP (Omada controller)
- **DNS:** Cloudflare, with a DDNS script maintaining current IP
- **VPN:** Tailscale across all nodes for secure remote access
- **Backups:** rclone to Google Drive, Dropbox, and Cloudflare R2; PostgreSQL dumps and other app-level backups shipped to TrueNAS separately
- **CalDAV:** Baïkal at `calendar.armstream.stream` (self-hosted, synced via DAVx5)

---

## Desktop

Daily drivers are a desktop PC and a Thinkpad T14 Gen. 4 Laptop, both running Fedora workstation with **KDE Plasma**, migrated the Thinkpad from a prior NixOS setup after a multi-failure update cycle. A parallel **NixOS** configuration ([nixos-config](https://github.com/yeghia-s/nixos-config)) maintains a declarative Hyprland setup with Home Manager, flakes, sops-nix, four-layout keyboard (us/ca/de/am phonetic), Syncthing, Steam/Proton-GE, goodix-550a fingerprint driver, and TLP with 20/80 charge thresholds.

---

## Related Repositories

- [nixos-config](https://github.com/yeghia-s/nixos-config) — declarative NixOS + Hyprland configuration
- [nvim-config](https://github.com/yeghia-s/nvim-config) — portable Neovim config with lazy.nvim + Mason, DAP debugging (codelldb, debugpy)
- [mumblebot](https://github.com/yeghia-s/mumblebot) — Python Mumble music bot
