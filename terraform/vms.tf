# VM resources will go here
resource "proxmox_virtual_environment_vm" "test" {
  name      = "terraform-test"
  node_name = "proxmox"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
    interface    = "virtio0"
  }

  network_device {
    bridge = "vmbr0"
  }
}
