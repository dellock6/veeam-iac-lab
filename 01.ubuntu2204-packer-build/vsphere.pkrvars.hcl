##################################################################################
# VARIABLES
##################################################################################

# Credentials

vcenter_username                = "administrator@cloudconnect.local"
vcenter_password                = "Veeam123!"

# vSphere Objects

vcenter_insecure_connection     = true
vcenter_server                  = "vcenter.cloudconnect.local"
vcenter_datacenter              = "VCC_DC"
vcenter_host                    = "esx12.cloudconnect.local"
vcenter_datastore               = "vsanDatastore"
vcenter_network                 = "DPG-vcc-mgmt"
vcenter_folder                  = "Templates"

# ISO Objects
iso_path                        = "[vsanDatastore] contentlib-5ed427e9-8cf4-442a-8218-14a8d3cc9dc3/ab0bf964-474e-4e4d-90dd-a324b392d660/ubuntu-22.04.2-live-server-amd64_1641f4b9-dbe1-409a-9433-7cd39c9dbfe7.iso"
