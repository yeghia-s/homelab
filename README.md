# Homelab

A self-hosted infrastructure project running on a repurposed HP Pavilion h8 tower. Built from the ground up — bare metal installation, ZFS storage, full VM provisioning via Terraform, and a complete self-hosted service stack covering media, communications, monitoring, and community infrastructure.

---

## Hardware

| Component | Spec |
|-----------|------|
| **Case** | HP Pavilion h8 Tower |
| **CPU** | AMD FX-8350 Eight-Core @ 4.0GHz (AM3+, 125W TDP) |
| **RAM** | 32GB Timetec DDR3 1600MHz (4×8GB) |
| **Boot Drive** | Crucial BX500 240GB SATA SSD |
| **Storage** | 12TB HGST Ultrastar HUH721212ALE601 (ZFS pool `tank`) |

> Planning upgrade to Ryzen 5600G + B550 Mini-ITX for proper IOMMU passthrough, DDR4, and lower power draw (~65W vs 125W TDP).

---

## Architecture

**Proxmox VE 9.1** runs bare metal on the SSD. All services are isolated in VMs provisioned via Terraform using the `bpg/proxmox` provider. Terraform remote state is stored in a MinIO S3 bucket on TrueNAS.

Network routing is handled by a **TP-Link ER707-M2** (gateway `10.0.0.2`) with Wi-Fi via TP-Link EAP670 AP (Omada stack). Dynamic DNS is kept current via a Cloudflare DDNS script. All external traffic terminates at the Nginx reverse proxy with Certbot-issued SSL per subdomain.

### VM Inventory

| VM ID | Role | OS | Key Services |
|-------|------|----|--------------|
| 100 | NAS | TrueNAS SCALE | ZFS pool `tank`, MinIO (S3 remote state) |
| 101 | Monitoring | Ubuntu | Prometheus, Grafana, alerting (SMTP) |
| 102 | Reverse Proxy | Debian | Nginx, Certbot, SSL termination |
| 103 | Community | Debian | Stoat (self-hosted Revolt), Mumble, LiveKit |
| 104 | Game Server | Ubuntu | open.mp (GTA:SA RPG server) |
| 105 | Wiki | Debian | DokuWiki (HyeTechWiki) |
| 106 | E-Commerce | Debian | Nairi Café (Medusa.js v2 + custom storefront) |
| 107 | Blog | Debian | Ghost (yeghiasargis.com) |
| 108 | Git | Debian | Gitea (git.armstream.stream) |

---

## Services

### Storage — TrueNAS SCALE (VM 100)
ZFS pool `tank` on the 12TB HDD, passed through via stable disk ID. Hosts MinIO for S3-compatible Terraform remote state. Also runs Jellyfin, Calibre-Web (with Kobo Sage sync), Syncthing, Navidrome, Immich (12k+ photo assets), and Transmission.

### Monitoring — Ubuntu (VM 101)
Prometheus scrapes node-exporter from all VMs. Grafana dashboards provide full visibility across the stack. Alert rules configured for high disk (>90%), RAM (>95%), CPU (>95%), and host-down events, delivered via SMTP.

### Reverse Proxy — Debian (VM 102)
Nginx handles all inbound HTTPS traffic, routing by subdomain to internal services. SSL certificates issued per subdomain via Certbot against Cloudflare DNS.

### Community — Debian (VM 103)
**Stoat** (self-hosted [Revolt](https://revolt.chat)) at `chat.armstream.stream` — fully self-hosted chat platform. **LiveKit** provides voice/video (TCP 7881, UDP 50000–50100 forwarded at router). **Mumble** at `voice.armstream.stream:64738` for low-latency voice. Custom Python Mumble music bot ([mumblebot](https://github.com/yeghia-s/mumblebot)) using pymumble + yt-dlp + ffmpeg.

### Game Server — Ubuntu (VM 104)
open.mp GTA:SA RPG server with a working account system, economy, and class selection. Source: [omp-rpg](https://github.com/yeghia-s/omp-rpg).

### Wiki — Debian (VM 105)
[HyeTechWiki](https://wiki.hyetechnology.org) — DokuWiki instance with Bootstrap3 theme. An Armenian-language technical wiki for Armenian developers in both the homeland and diaspora.

### E-Commerce — Debian (VM 106)
Nairi Café storefront — Medusa.js v2 backend with a custom frontend and Stripe payment integration.

### Blog — Debian (VM 107)
Ghost instance at [yeghiasargis.com](https://yeghiasargis.com). Canonical home for the *Built and Written* weekly; Substack used for syndication only.

### Git — Debian (VM 108)
Self-hosted [Gitea](https://git.armstream.stream) instance at `git.armstream.stream` (SSH on port 2222). Primary remote for personal repositories, with Obsidian vault sync via Tailscale + HTTPS using a Gitea access token in `~/.netrc`.

---

## Infrastructure as Code

All VMs are provisioned via **Terraform** using the `bpg/proxmox` provider. Remote state is stored in a **MinIO S3 bucket** on TrueNAS, keeping state off local disk and enabling consistent provisioning.

```
homelab/
└── terraform/
    ├── main.tf
    ├── variables.tf
    └── ...
```

---

## Networking

- **Router:** TP-Link ER707-M2 (gateway `10.0.0.2`)
- **Wi-Fi:** TP-Link EAP670 AP (Omada controller)
- **DNS:** Cloudflare, with a DDNS script maintaining current IP
- **VPN:** Tailscale across all nodes for secure remote access
- **Backups:** rclone to Google Drive, Dropbox, and Cloudflare R2
- **CalDAV:** Baïkal at `calendar.armstream.stream` (self-hosted, synced via DAVx5)

---

## Desktop

Daily driver is a Fedora workstation running **Hyprland** (Wayland compositor) via UWSM, with Waybar, Wofi, dunst, hyprlock, and hypridle. Login managed by greetd + tuigreet (replacing GDM). A parallel **NixOS** configuration ([nixos-config](https://github.com/yeghia-s/nixos-config)) maintains the same Hyprland setup declaratively, with Home Manager, flakes, sops-nix, four-layout keyboard (us/ca/de/am phonetic), Syncthing, Steam/Proton-GE, goodix-550a fingerprint driver, and TLP with 20/80 charge thresholds.

---

## Related Repositories

- [nixos-config](https://github.com/yeghia-s/nixos-config) — declarative NixOS + Hyprland configuration
- [nvim-config](https://github.com/yeghia-s/nvim-config) — portable Neovim config with lazy.nvim + Mason
- [mumblebot](https://github.com/yeghia-s/mumblebot) — Python Mumble music bot
- [omp-rpg](https://github.com/yeghia-s/omp-rpg) — GTA:SA open.mp RPG server
