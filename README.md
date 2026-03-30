# Veeam IAC lab

This is a small repository where I'm collecting the components I use to create my Veeam lab, leveraging vSphere hypervisor as the underlying infrastructure.

Here I'm collecting all the automation scripts that I create for my home lab.
What' available?

Packer:
  - ubuntu2404: create a Ubuntu 24.04 template using Packer
  - ubuntu2204: create a Ubuntu 22.04 template using Packer
  - win2019: create a Windows 2019 template using Packer

Terraform:
  - vbr: deploy a Windows VM for VBR (Veeam Backup & Replication) Server using Terraform
  - lhr: deploy a Ubuntu Linux 22.04 VM with one additional disk formatted with XFS and reflink enabled for Linux Hardened Repository
  - aws-s3: create a aws S3 bucket with object lock
  - pykmip: build a Ubuntu Linux 24.04 VM and installs pyKMIP into it, to build a complete KMS server for personal use