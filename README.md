# Homelab

A self-hosted infrastructure project running on a repurposed HP Pavilion h8 tower. Built to learn DevOps concepts hands-on — virtualization, storage, monitoring, reverse proxying, and infrastructure as code.

All VMs are provisioned and managed via **Terraform** (bpg/proxmox provider) with **MinIO S3 remote state** stored on TrueNAS.

---

## Hardware

**Case:** HP Pavilion h8 Tower
**CPU:** AMD FX-8350 Eight-Core @ 4.0GHz (AM3+, 125W TDP)
**RAM:** 32GB Timetec DDR3 1600MHz (4x8GB)
**Boot Drive:** Crucial BX500 240GB SATA SSD (Proxmox OS)
**Storage:** 12TB HGST Ultrastar HUH721212ALE601 (ZFS pool `tank`, passed through to TrueNAS)

> **Platform notes:** DDR3 only, no ECC support, limited IOMMU capability. Planning upgrade to Ryzen 5600G + B550 Mini-ITX platform for proper IOMMU passthrough, DDR4, and lower power draw (65W vs 125W TDP).

---

## Network

**Router:** TP-Link ER707-M2 (Rogers XB6 in bridge mode)
**AP:** TP-Link EAP670
**Gateway:** `10.0.0.2`

All VMs are assigned static IPs on the `10.0.0.0/24` subnet. DNS is managed via **Cloudflare** with records pointing to the Nginx reverse proxy (VM 102) for external access. DDNS update script keeps `armstream.stream` in sync.

---

## Stack Overview

**Hypervisor:** Proxmox VE 9.1 (bare metal on 240GB SSD)
**IaC:** Terraform with bpg/proxmox provider, MinIO S3 remote state on TrueNAS
**Reverse Proxy:** Nginx + Certbot (Let's Encrypt), Cloudflare DNS

---

## Virtual Machines

| VM ID | Name | IP | Description |
| --- | --- | --- | --- |
| 100 | TrueNAS | `10.0.0.143` | NAS — ZFS pool, file storage, MinIO S3, rclone backups |
| 101 | Monitoring | `10.0.0.238` | Prometheus + Grafana + node-exporter |
| 102 | Nginx | `10.0.0.251` | Reverse proxy + SSL termination for all services |
| 103 | Community | `10.0.0.160` | Stoat (Revolt), Mumble, LiveKit voice/video |
| 104 | OMP | `10.0.0.161` | open.mp GTA:SA multiplayer server (RPG gamemode) |
| 105 | DokuWiki | `10.0.0.162` | [hyetechnology.org](https://hyetechnology.org) — Armenian tech community wiki |
| 106 | Nairi Café | `10.0.0.163` | [nairicafe.com](https://nairicafe.com) — e-commerce storefront |
| 107 | Ghost | `10.0.0.164` | [yeghiasargis.com](https://yeghiasargis.com) — personal blog |
| 108 | Nextcloud | `10.0.0.165` | Self-hosted Google Workspace replacement — files, calendar, contacts, documents |

---

## Services

### TrueNAS SCALE 25.10.2 — VM 100

NAS VM with the 12TB HDD passed through via stable disk ID. ZFS pool `tank` auto-imported on setup.

**Hosted apps:**

* Jellyfin — media server
* Navidrome — self-hosted music streaming
* Calibre-Web — ebook library with Kobo Sage sync
* Immich — self-hosted photo library (migrated from Google Photos, ~12,000 assets) at `photos.armstream.stream`
* Syncthing — file sync
* Transmission — torrent client
* MinIO — S3-compatible object storage (Terraform remote state backend)
* node-exporter — metrics

**Backups:**

* rclone to Google Drive, Dropbox, and Cloudflare R2 (three destinations)
* TrueNAS periodic snapshots

---

### Monitoring — VM 101

Prometheus + Grafana stack. Scrapes metrics from all VMs via node-exporter.

**Grafana dashboard:** Node Exporter Full (ID 1860)

**Alert rules:**

* High Disk — usage > 90%
* High RAM — usage > 95%
* High CPU — usage > 95%
* Host Down — `up == 0`

Alerts delivered via SMTP.

---

### Nginx Reverse Proxy — VM 102 (`10.0.0.251`)

Nginx with Certbot SSL termination. Routes all external HTTPS traffic to internal services.

**Proxied services (armstream.stream subdomains):**

* `photos.armstream.stream` → Immich
* `cloud.armstream.stream` → Nextcloud
* `onlyoffice.armstream.stream` → OnlyOffice document server
* `chat.armstream.stream` → Stoat
* `navidrome.armstream.stream` → Navidrome
* `calibre.armstream.stream` → Calibre-Web
* `jellyfin.armstream.stream` → Jellyfin

**Proxied services (external domains):**

* `yeghiasargis.com` → Ghost (VM 107)
* `hyetechnology.org` → DokuWiki (VM 105)
* `nairicafe.com` → e-commerce (VM 106)

---

### Community — VM 103 (`10.0.0.160`)

Self-hosted community infrastructure for the Armenian tech community (armstream.stream).

* **Stoat** (rebranded Revolt) — self-hosted chat at `chat.armstream.stream`
* **LiveKit** — voice/video conferencing backend for Stoat
* **Mumble** — low-latency voice server
* **Mumble music bot** — custom Python bot (pymumble + yt-dlp + ffmpeg)

---

### open.mp GTA:SA Server — VM 104 (`10.0.0.161`)

open.mp (SA-MP successor) game server running a custom RPG gamemode.

* MySQL backend for persistent player data
* Account system (register/login)
* Class selection
* Economy commands

---

### DokuWiki — VM 105 (`10.0.0.162`)

[hyetechnology.org](https://hyetechnology.org) — an Armenian tech community knowledge base and wiki. Provisioned via Terraform.

---

### Nairi Café — VM 106 (`10.0.0.163`)

[nairicafe.com](https://nairicafe.com) — e-commerce storefront. Provisioned via Terraform.

---

### Ghost — VM 107 (`10.0.0.164`)

[yeghiasargis.com](https://yeghiasargis.com) — personal blog covering self-hosted infrastructure, Linux, and humanistic essays. Provisioned via Terraform.

---

### Nextcloud — VM 108 (`10.0.0.165`)

Self-hosted Google Workspace replacement at `cloud.armstream.stream`. Deployed via Docker Compose with Nextcloud, Postgres, Redis, and OnlyOffice. Data directory mounted from TrueNAS via NFS (`tank/nextcloud`).

**Apps enabled:**

* Calendar — CalDAV server, replaces Baïkal
* Contacts — CardDAV server
* OnlyOffice — document editing at `onlyoffice.armstream.stream`
* Tasks
* Notes

**Integrations:**

* DAVx5 on GrapheneOS for native calendar/contacts sync
* vdirsyncer + khal on NixOS for desktop calendar sync
* Secrets managed via sops-nix

---

## Infrastructure as Code

All VMs are defined in Terraform using the **bpg/proxmox** provider.

* Remote state stored in **MinIO S3** on TrueNAS (`tank`)
* Secrets passed via environment variables (`TF_VAR_*`) — never committed
* `.tfvars` and credential files excluded via `.gitignore`

---

## Roadmap

* ~~Nextcloud — self-hosted file sync and document editing~~ ✓
* Hardware upgrade — Ryzen 5600G + B550 Mini-ITX + 32GB DDR4
* GNOME/KDE translation contributions for Armenian locale (hyetechnology.org initiative)

---

## Related

* [NixOS config](https://github.com/yeghia-s/nixos-config)
* [Neovim config](https://github.com/yeghia-s/nvim-config)
