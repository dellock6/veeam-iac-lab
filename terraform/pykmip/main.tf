terraform {
  required_version = ">= 0.14.7"
  required_providers {
    vsphere = {
      source = "vmware/vsphere"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  count         = var.vsphere_cluster == "" ? 0 : 1
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "esxihost" {
  count         = var.vsphere_cluster == "" ? 1 : 0
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "pykmip" {
  name             = var.host_name
  resource_pool_id = var.vsphere_cluster == "" ? data.vsphere_host.esxihost[0].resource_pool_id : data.vsphere_compute_cluster.cluster[0].resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.host_vm_folder

  num_cpus  = var.host_cpu
  memory    = var.host_ram_mb
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  firmware  = data.vsphere_virtual_machine.template.firmware

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    unit_number      = 0
    size             = var.host_disk_gb
    eagerly_scrub    = false
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.host_name
        domain    = var.host_domain
      }

      network_interface {
        ipv4_address = var.host_ip
        ipv4_netmask = var.host_subnet
      }

      ipv4_gateway    = var.host_gateway
      dns_server_list = var.dns_server_list
      dns_suffix_list = var.dns_suffix_list
    }
  }

  connection {
    type     = "ssh"
    agent    = "false"
    host     = var.host_ip
    user     = var.host_user
    password = var.host_password
  }

provisioner "file" {
    source      = "${path.module}/provision_pykmip.sh"
    destination = "/tmp/provision_pykmip.sh"

    connection {
      type     = "ssh"
      host     = var.host_ip
      user     = var.host_user
      password = var.host_password
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = var.host_ip
      user     = var.host_user
      password = var.host_password
    }

    inline = [
      "chmod +x /tmp/provision_pykmip.sh",
      "sudo bash /tmp/provision_pykmip.sh ${var.host_ip} ${var.host_name} ${var.host_domain}"
    ]
  }
}
