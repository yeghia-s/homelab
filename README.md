# Homelab

A self-hosted infrastructure project running on a repurposed HP Pavilion h8 tower. Built to learn DevOps concepts hands-on — virtualization, storage, monitoring, reverse proxying, and infrastructure as code.

---

## Hardware

**Case:** HP Pavilion h8 Tower

**CPU:** AMD FX-8350 Eight-Core @ 4.0GHz (AM3+, 125W TDP)

**RAM:** 32GB Timetec DDR3 1600MHz (4x8GB)

**Boot Drive:** Crucial BX500 240GB SATA SSD

**Storage:** 12TB HGST Ultrastar HUH721212ALE601 (ZFS pool `tank`)

> **Platform notes:** DDR3 only, no ECC support, limited IOMMU capability. Planning upgrade to Ryzen 5600G + B550 Mini-ITX platform in ~1 year for proper IOMMU passthrough, DDR4, and significantly lower power draw (65W vs 125W TDP).

---

## Stack Overview

**Proxmox 9.1** (bare metal)
- **TrueNAS SCALE VM** — Jellyfin, Calibre-Web, Syncthing, Transmission, node-exporter
- **Ubuntu Monitoring VM** — Prometheus, Grafana, node-exporter, SMTP alerts
- **Debian Nginx VM** — Nginx, Certbot (reverse proxy + SSL)

---

## Services

### Proxmox 9.1

Hypervisor running on the 240GB SSD boot drive. Hosts all VMs.

**Notable troubleshooting:**
- PSU cutting out due to loose dangling SATA power cable from previously removed drives
- RAM required firm reseating; one slot was stiff from years of disuse
- 12TB HDD not detected when sharing a SATA power cable with the SSD — required a dedicated power cable

---

### TrueNAS SCALE 25.10.2 (Goldeye)

NAS VM with 32GB virtual boot disk. The 12TB HDD is passed through using its stable disk ID rather than `/dev/sdX` to ensure consistent assignment across reboots. ZFS pool `tank` auto-imported on setup with all data intact.

**Apps running:**
- Jellyfin (media server)
- Calibre-Web (ebook library)
- Syncthing (file sync)
- Transmission (torrent client)
- node-exporter (metrics)

**Notable troubleshooting:**
- node-exporter crashed after VM migration; required manual restart from TrueNAS Apps UI

---

### Ubuntu Monitoring VM

Dedicated monitoring VM running Prometheus and Grafana.

**Prometheus** scrapes metrics from the monitoring VM and TrueNAS via node-exporter.

**Grafana** dashboard: [Node Exporter Full (ID 1860)](https://grafana.com/grafana/dashboards/1860)

**Alert rules configured:**
- High Disk — usage > 90%
- High RAM — usage > 95%
- High CPU — usage > 95%
- Host Down — `up == 0`

Alerts delivered via SMTP (Yahoo Mail).

**Notable troubleshooting:**
- `prometheus.yml` YAML formatting error when adding TrueNAS scrape target — targets must be on the same line in array format, not broken across lines

---

### Debian Nginx VM

Reverse proxy with SSL termination via Certbot. Routes external HTTPS traffic to internal services.

**Proxied services:**
- Jellyfin
- Grafana
- Calibre-Web

DNS managed via Cloudflare. SSL certificates issued per subdomain via Certbot.

**Notable troubleshooting:**
- `sudo` and `usermod` not found on Debian minimal install — required full binary paths (`/usr/sbin/usermod`)

---

## Network

All VMs are assigned static IPs on the local network. DNS is managed via Cloudflare with wildcard records pointing to the Nginx reverse proxy for external access.

---

## Roadmap

- [ ] Terraform — codify Proxmox VM provisioning with IaC
- [ ] Restrict Grafana — lock down public access via Nginx auth
- [ ] Nextcloud + ONLYOFFICE — self-hosted document editing
- [ ] Syncthing — connect mobile device
- [ ] Hardware upgrade — Ryzen 5600G + B550 Mini-ITX + 32GB DDR4 (~$475–490 USD)

---

## Related

- [NixOS config](https://github.com/yeghia-s/nixos-config)
