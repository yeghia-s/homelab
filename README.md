# Homelab

A self-hosted infrastructure project running on a repurposed HP Pavilion h8 tower. Built to learn DevOps concepts hands-on — virtualization, storage, monitoring, reverse proxying, and infrastructure as code.

---

## Hardware

**Case:** HP Pavilion h8 Tower  
**CPU:** AMD FX-8350 Eight-Core @ 4.0GHz (AM3+, 125W TDP)  
**RAM:** 32GB Timetec DDR3 1600MHz (4×8GB)  
**Boot Drive:** Crucial BX500 240GB SATA SSD  
**Storage:** 12TB HGST Ultrastar HUH721212ALE601 (ZFS pool `tank`)

> **Platform notes:** DDR3 only, no ECC support, limited IOMMU capability. Planning upgrade to Ryzen 5600G + B550 Mini-ITX platform in ~1 year for proper IOMMU passthrough, DDR4, and significantly lower power draw (65W vs 125W TDP).

---

All VMs are codified with Terraform using the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider. See [`terraform/`](./terraform/).

---

## Services

### TrueNAS SCALE 25.10.2 (Goldeye)

NAS VM with 32GB virtual boot disk. The 12TB HDD is passed through using its stable disk ID rather than `/dev/sdX` to ensure consistent assignment across reboots. ZFS pool `tank` auto-imported on setup with all data intact.

**Running apps:** Jellyfin · Calibre-Web · Syncthing · Transmission · node-exporter · MinIO

> MinIO on TrueNAS serves as the S3-compatible remote backend for Terraform state storage (`terraform-state` bucket).

---

### Ubuntu Monitoring VM

Prometheus scrapes metrics from the monitoring VM and TrueNAS via node-exporter. Grafana dashboard: [Node Exporter Full (ID 1860)](https://grafana.com/grafana/dashboards/1860). Alerts delivered via SMTP.

**Alert rules:** High Disk (>90%) · High RAM (>95%) · High CPU (>95%) · Host Down

---

### Debian Nginx VM

Reverse proxy with SSL termination via Certbot. Routes external HTTPS traffic to internal services. DNS managed via Cloudflare.

**Proxied services:** Jellyfin · Grafana · Calibre-Web · Navidrome · Stoat (Revolt)

---

### Debian Community VM

Dedicated VM for community and communication services. Runs Docker Compose stacks for Stoat and Mumble.

**Stoat (self-hosted Revolt)** — Discord-like chat platform accessible at `chat.armstream.stream`. Deployed via the official [stoatchat/self-hosted](https://github.com/stoatchat/self-hosted) repo. Includes text channels, DMs, file sharing, roles, and voice via LiveKit.

> Workarounds applied for AMD FX-8350 (no AVX support): MongoDB pinned to 4.4, Redis overridden to `redis:7-alpine` in `compose.override.yml`.

**Mumble** — Low-latency voice server. Deployed as a separate Docker Compose stack. DNS record is grey-cloud (DNS only) to allow raw TCP/UDP passthrough.

---

### Debian open.mp VM

Dedicated VM for a self-hosted [open.mp](https://open.mp) (GTA San Andreas multiplayer) game server. Runs a custom RPG gamemode built on Pawn with sscanf and streamer components. Managed as a systemd service.

---

## Infrastructure as Code

All VMs are managed with Terraform. The `terraform/` directory contains:
```
terraform/
├── backend.tf        # S3 remote state backend (MinIO on TrueNAS)
├── providers.tf      # bpg/proxmox provider
├── variables.tf      # endpoint, API token, SSH key variables
├── vms.tf            # VM resource definitions
└── terraform.tfvars  # gitignored — secrets only
```

Terraform state is stored remotely in MinIO on TrueNAS. Credentials are passed via environment variables:
```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

To initialize:
```bash
cd terraform
terraform init
terraform plan
```

A Debian 13 cloud-init template (VM ID 9000) is used as the base for cloned VMs. Created manually on the Proxmox host using the official Debian genericcloud image.

---

## Roadmap

- [x] Proxmox hypervisor setup
- [x] TrueNAS SCALE with ZFS passthrough
- [x] Prometheus + Grafana monitoring
- [x] Nginx reverse proxy with SSL
- [x] Terraform — all VMs codified with IaC
- [x] Terraform remote state backend via MinIO on TrueNAS
- [x] Debian 13 cloud-init template for VM provisioning
- [x] Stoat (self-hosted Revolt) — community chat
- [x] Mumble — voice server
- [x] Hardware upgrade — Ryzen 5600G + B550 Mini-ITX + 32GB DDR4
- [x] open.mp game server — custom RPG gamemode
- [ ] Restrict Grafana behind Nginx auth
- [ ] Nextcloud + ONLYOFFICE
- [ ] open.mp — NPC bots and expanded RPG features

---

## Related

- [NixOS config](https://github.com/yeghia-s/nixos-config)
