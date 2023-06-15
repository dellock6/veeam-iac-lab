variable "vsphere_user" {
  description = "vsphere username"
}

variable "vsphere_password" {
  description = "vsphere password"
}

variable "vsphere_server" {
  description = "vsphere_server"
}

variable "vsphere_datacenter" {
  description = "vsphere datacenter name"
}

variable "vsphere_datastore" {
  description = "vsphere_datastore"
}

variable "vsphere_cluster" {
  description = "vsphere_cluster"
}

variable "vsphere_network" {
  description = "vsphere_network"
}

variable "vsphere_template" {
  description = "vsphere_template"
}

variable "host_name" {
  description = "host_name"
}

variable "host_domain" {
  description = "host_domain"
}

variable "host_ip" {
  description = "host_ip"
}

variable "host_user" { }
variable "host_password" {}
variable "host_cpu" { default=1 }
variable "host_ram_mb" { default=1024 }
variable "host_disk_gb" { default=20 }
variable "host_vm_folder" { default="" }

variable "dns_server_list" { 
  type = list(string)
  default = [ ]
}
variable "dns_suffix_list" { 
  type = list(string)
  default = [ ]
}


variable "host_subnet" {
  description = "host_subnet"
}

variable "host_gateway" {
  description = "host_gateway"
}

