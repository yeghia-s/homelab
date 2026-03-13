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

All three VMs are codified with Terraform using the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider. See [`terraform/`](./terraform/).

---

## Services

### TrueNAS SCALE 25.10.2 (Goldeye)

NAS VM with 32GB virtual boot disk. The 12TB HDD is passed through using its stable disk ID rather than `/dev/sdX` to ensure consistent assignment across reboots. ZFS pool `tank` auto-imported on setup with all data intact.

**Running apps:** Jellyfin · Calibre-Web · Syncthing · Transmission · node-exporter

---

### Ubuntu Monitoring VM

Prometheus scrapes metrics from the monitoring VM and TrueNAS via node-exporter. Grafana dashboard: [Node Exporter Full (ID 1860)](https://grafana.com/grafana/dashboards/1860). Alerts delivered via SMTP.

**Alert rules:** High Disk (>90%) · High RAM (>95%) · High CPU (>95%) · Host Down

---

### Debian Nginx VM

Reverse proxy with SSL termination via Certbot. Routes external HTTPS traffic to Jellyfin, Grafana, and Calibre-Web. DNS managed via Cloudflare wildcard records.

---

## Infrastructure as Code

All VMs are managed with Terraform. The `terraform/` directory contains:
```
terraform/
├── providers.tf      # bpg/proxmox provider
├── variables.tf      # endpoint + API token variables
├── vms.tf            # VM resource definitions
└── terraform.tfvars  # gitignored — secrets only
```

To initialize:
```bash
cd terraform
terraform init
terraform plan
```

---

## Roadmap

- [x] Proxmox hypervisor setup
- [x] TrueNAS SCALE with ZFS passthrough
- [x] Prometheus + Grafana monitoring
- [x] Nginx reverse proxy with SSL
- [x] Terraform — all VMs codified with IaC
- [ ] Restrict Grafana behind Nginx auth
- [ ] Nextcloud + ONLYOFFICE
- [ ] Hardware upgrade — Ryzen 5600G + B550 Mini-ITX + 32GB DDR4

---

## Related

- [NixOS config](https://github.com/yeghia-s/nixos-config)
