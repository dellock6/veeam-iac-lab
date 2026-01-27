##################################################################################
# VARIABLES
##################################################################################

# HTTP Settings

http_directory = "http"

# Virtual Machine Settings

vm_name                     = "ubuntu2404"
vm_guest_os_type            = "ubuntu64Guest"
vm_version                  = 21
vm_firmware                 = "efi"
vm_cdrom_type               = "sata"
vm_cpu_sockets              = 1
vm_cpu_cores                = 2
vm_mem_size                 = 4096
vm_disk_size                = 20480
thin_provision              = true
disk_eagerly_scrub          = false
vm_disk_controller_type     = ["pvscsi"]
vm_network_card             = "vmxnet3"
vm_boot_wait                = "5s"
ssh_username                = "ubuntu"
ssh_password                = "your_password"

# ISO Objects

iso_file                    = "ubuntu-24.04.3-live-server-amd64.iso"
iso_checksum                = "c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
iso_path                    = "[ISO] template/iso/ubuntu-24.04.3-live-server-amd64.iso"
iso_checksum_type           = "sha256"
iso_url                     = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso" 
