##################################################################################
# VARIABLES
##################################################################################

# HTTP Settings

http_directory = "http"

# Virtual Machine Settings

vm_name                     = "win2019"
vm_guest_os_type            = "windows2019srv_64Guest"
vm_version                  = 17
vm_firmware                 = "bios"
vm_cdrom_type               = "sata"
vm_cpu_sockets              = 1
vm_cpu_cores                = 2
vm_mem_size                 = 4096
vm_disk_size                = 40960
thin_provision              = true
disk_eagerly_scrub          = false
vm_disk_controller_type     = ["lsilogic-sas"]
vm_network_card             = "vmxnet3"
vm_boot_wait                = "5s"
winadmin_username           = "Administrator"
winadmin_password           = "Password!"

# ISO Objects

os_iso_path                 = "[vsanDatastore]  contentlib-uuid/folder-uuid/Windows_Server_2019.iso"
vmtools_iso_path            = "[vsanDatastore]  contentlib-uuid/folder-uuid/windows_vmtools.iso"
