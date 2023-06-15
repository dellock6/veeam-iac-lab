# veeam-iac-lab

Here I'm collecting all the components for creating a small Veeam lab:

packer:
  - ubuntu2204: create a Ubuntu 22.04 template using Packer
  - win2019: create a Windows 2019 template using Packer
4.	Deploy windows VM for VBR using Terraform
5.	Deploy linux vm with custom disks for LHR (with xfs and reflink already enabled)
6.	Create aws S3 bucket with object lock
7.	Bonus (I can show it) crate all the dns records with Ansible in a windows dns server
