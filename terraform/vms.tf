resource "proxmox_virtual_environment_vm" "truenas" {
  name          = "truenas"
  node_name     = "proxmox"
  vm_id         = 100
  started       = true
  on_boot       = true
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

  agent {
    enabled = true
  }

  startup {
    order      = 1
    up_delay   = 10
    down_delay = -1
  }
}

resource "proxmox_virtual_environment_vm" "monitoring" {
  name          = "monitoring"
  node_name     = "proxmox"
  vm_id         = 101
  started       = true
  on_boot       = true
  scsi_hardware = "virtio-scsi-single"

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
    size         = 48
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:40:AC:B1"
    firewall    = true
  }

  agent {
    enabled = true
  }
}

resource "proxmox_virtual_environment_vm" "nginx" {
  name          = "nginx"
  node_name     = "proxmox"
  vm_id         = 102
  started       = true
  on_boot       = true
  scsi_hardware = "virtio-scsi-single"

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
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:BD:9C:64"
    firewall    = true
  }

  agent {
    enabled = true
  }
}

resource "proxmox_virtual_environment_vm" "community_vm" {
  name      = "community"
  node_name = "proxmox"
  vm_id     = 103
  started   = true
  on_boot   = true

  clone {
    vm_id = 9000
    full  = true
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
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.160/24"
        gateway = "10.0.0.2"
      }
    }
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
    user_account {
      username = "yeghia"
      keys = var.ssh_public_keys
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  lifecycle {
  ignore_changes = [initialization[0].user_account[0].keys]
}
}

resource "proxmox_virtual_environment_vm" "dokuwiki" {
  name      = "dokuwiki"
  node_name = "proxmox"
  vm_id     = 105
  started   = true
  on_boot   = true

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores   = 1
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 8
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.162/24"
        gateway = "10.0.0.2"
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

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  lifecycle {
  ignore_changes = [
    cdrom,
    initialization[0].user_account[0].keys,
  ]
}
}

resource "proxmox_virtual_environment_vm" "ghost" {
  name      = "ghost"
  node_name = "proxmox"
  vm_id     = 107
  started   = true
  on_boot   = true

  clone {
    vm_id = 9000
    full  = true
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
    interface    = "scsi0"
    size         = 20 
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.164/24"
        gateway = "10.0.0.2"
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

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  lifecycle {
  ignore_changes = [
    cdrom,
    initialization[0].user_account[0].keys,
  ]
}
}

resource "proxmox_virtual_environment_vm" "gentoo" {
  name         = "gentoo"
  node_name    = "proxmox"
  vm_id        = 106          
  started       = true
  on_boot       = true
  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"  
    size         = 20
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    firewall    = true
  }

  agent {
    enabled = false
  }

  initialization {
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    ip_config {
      ipv4 {
        address = "10.0.0.163/24" 
        gateway = "10.0.0.2"
      }
    }

    user_account {
      username = "yeghia"
      keys = var.ssh_public_keys
    }
  }

    cdrom {
      file_id = "local:iso/install-amd64-minimal-20260906T170102Z.iso"
    }

    lifecycle {
  ignore_changes = [initialization[0].user_account[0].keys]
}

}

resource "proxmox_virtual_environment_vm" "winserver" {
  name          = "winserver"
  node_name     = "proxmox"
  vm_id         = 108
  started       = false
  on_boot       = false
  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["terraform", "windows"]

  operating_system {
    type = "win11"
  }

  agent { enabled = true }

  cpu {
    cores = 2
    type  = "host"
  }

  memory { dedicated = 4096 }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 40
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  cdrom {
    file_id   = "local:iso/26100.32230.260111-0550.lt_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
    interface = "ide0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
}
