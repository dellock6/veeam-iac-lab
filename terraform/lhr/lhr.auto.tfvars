# vcenter credentials
vsphere_user          = "Administrator@vsphere.local"
vsphere_password      = "Password!"
vsphere_server        = "vcenter.vsphere.local"
vsphere_datacenter    = "DATACENTER"
vsphere_datastore     = "Datastore"
vsphere_cluster       = "Cluster"
vsphere_network       = "VM Netowkr"

# name of template
vsphere_template      = "ubuntu2204"

# OS template credentials
host_user             = "ubuntu"
host_password         = "Password!"

host_name             = "lhr"
host_vm_folder        = "IAC Lab"
host_domain           = "demo.lab"
host_cpu              = "4"
host_ram_mb           = "2048"
host_ip               = "192.168.1.12"
host_subnet           = "24"
host_gateway          = "192.168.1.1"
dns_server_list       = [ "192.168.1.1" ]
dns_suffix_list       = [ "demo.lab" ]
