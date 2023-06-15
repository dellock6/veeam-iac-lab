# veeam-iac-lab

Here I'm collecting all the components for creating a small Veeam lab:

packer:
  - ubuntu2204: create a Ubuntu 22.04 template using Packer
  - win2019: create a Windows 2019 template using Packer

terraform:
  - vbr: deploy a Windows VM for VBR (Veeam Backup & Replication) Server using Terraform
  - lhr: deploy a Ubuntu Linux 22.04 VM with additional disk formatted with XFS and reflink enabled for Linux Hardened Repository
  - 
6.	Create aws S3 bucket with object lock
