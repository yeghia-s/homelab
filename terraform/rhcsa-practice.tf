resource "proxmox_virtual_environment_vm" "rhcsa_practice_1" {
  name      = "rhcsa-practice-1"
  node_name = "proxmox"
  vm_id     = 9101
  started   = true
  on_boot   = false

  clone {
    vm_id = proxmox_virtual_environment_vm.rocky_template.vm_id
    full  = true
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
    interface    = "scsi0"
    size         = 12
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.165/24"
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

  tags = ["rhcsa", "practice"]
}

resource "proxmox_virtual_environment_vm" "rhcsa_practice_2" {
  name      = "rhcsa-practice-2"
  node_name = "proxmox"
  vm_id     = 9102
  started   = true
  on_boot   = false

  clone {
    vm_id = proxmox_virtual_environment_vm.rocky_template.vm_id
    full  = true
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
    interface    = "scsi0"
    size         = 12
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.166/24"
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

  tags = ["rhcsa", "practice"]
}
