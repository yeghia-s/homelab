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
    ignore_changes = [cdrom]
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
    ignore_changes = [cdrom]
  }
}

resource "proxmox_virtual_environment_container" "postgresql" {
  node_name    = "proxmox"
  vm_id        = 104                   
  description  = "PostgreSQL database server"

  unprivileged = true

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"  
    size         = 16
  }

  mount_point {
    volume = "truenas-pgdata"
    path   = "/var/lib/postgresql"
    size   = "16G"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"             
  }

  initialization {
    hostname = "postgresql"

    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    ip_config {
      ipv4 {
        address = "10.0.0.161/24" 
        gateway = "10.0.0.2"
      }
    }

    user_account {
      keys = var.ssh_public_keys
    }
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  features {
    nesting = true
  }

  startup {
    order      = 2
    up_delay   = 60
    down_delay = -1
  }

  tags = ["database", "terraform"]
}

