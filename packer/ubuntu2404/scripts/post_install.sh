#!/bin/bash
# This script will be called after the first reboot of the VM and before taking the OVA image.
# It is placed in /tmp and run as root.

# Force any questions to be answered with defaults, see `man 7 debconf`
export DEBIAN_FRONTEND=noninteractive

# Set root password
echo -e "your_root_password\nyour_root_password" | passwd

# Cleanups

# From: https://jimangel.io/post/create-a-vm-template-ubuntu-18.04/
#Stop services for cleanup
service rsyslog stop

#clear audit logs
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

# prevent cloudconfig from preserving the original hostname
sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost

#cleanup apt
apt-get clean && apt-get autoclean

# cleans out all of the cloud-init cache / logs - this is mainly cleaning out networking info
sudo cloud-init clean --logs

# Clear current machine-id which is also used by systemd-network to get DHCP leases
echo > /etc/machine-id
echo > /var/lib/dbus-machine-id

# Enable SSH password authentication
echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/60-password-auth.conf
dpkg-reconfigure openssh-server
systemctl restart ssh
echo "lock_passwd: false" >> /etc/cloud/cloud.cfg.d/99-disable-lock.cfg
echo "disable_root: false" >> /etc/cloud/cloud.cfg.d/99-disable-lock.cfg
passwd -u ubuntu

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w

# disable cloud-init on cloned VMs
touch /etc/cloud/cloud-init.disabled