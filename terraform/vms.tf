resource "proxmox_virtual_environment_vm" "truenas" {
  name          = "truenas"
  node_name     = "proxmox"
  vm_id         = 100
  started       = true
  on_boot       = false
  scsi_hardware = "virtio-scsi-single"

  lifecycle {
    ignore_changes = [disk]
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:12:1B:43"
    firewall    = true
  }
}

resource "proxmox_virtual_environment_vm" "monitoring" {
  name          = "monitoring"
  node_name     = "proxmox"
  vm_id         = 101
  started       = true
  on_boot       = false
  scsi_hardware = "virtio-scsi-single"

  lifecycle {
    ignore_changes = [disk]
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:40:AC:B1"
    firewall    = true
  }
}

resource "proxmox_virtual_environment_vm" "nginx" {
  name          = "nginx"
  node_name     = "proxmox"
  vm_id         = 102
  started       = true
  on_boot       = false
  scsi_hardware = "virtio-scsi-single"

  lifecycle {
    ignore_changes = [disk]
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 1
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    size         = 16
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:BD:9C:64"
    firewall    = true
  }
}
