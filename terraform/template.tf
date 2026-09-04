resource "proxmox_download_file" "rocky_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  file_name    = "rocky9-genericcloud.img"
  overwrite    = false
}

resource "proxmox_virtual_environment_vm" "rocky_template" {
  name          = "rocky9-cloud"
  node_name     = "proxmox"
  vm_id         = 9001
  template      = true
  started       = false
  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_download_file.rocky_cloud_image.id
    interface    = "scsi0"
    size         = 10
    iothread     = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
    user_account {
      username = "yeghia"
      keys     = var.ssh_public_keys
    }
  }

  agent {
    enabled = true
  }

  lifecycle {
    ignore_changes = [network_device]
  }
}
