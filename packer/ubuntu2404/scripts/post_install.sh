#!/bin/bash
# This script will be called after the first reboot of the VM and before taking the OVA image.
# It is placed in /tmp and run as root.

# Force any questions to be answered with defaults, see `man 7 debconf`
export DEBIAN_FRONTEND=noninteractive

# Disable Cloud-Init
touch /etc/cloud/cloud-init.disabled

# APT Updates
apt-get update 
apt-get upgrade -y
apt-get autoremove -y

# Set root password
echo -e "Passw0rd.\nPassw0rd." | passwd

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

#add check for ssh keys on reboot...regenerate if neccessary
cat << 'EOL' | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
# dynamically create hostname (optional)
if hostname | grep localhost; then
    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
fi
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# make sure the script is executable
chmod +x /etc/rc.local

#reset hostname
# prevent cloudconfig from preserving the original hostname
sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost

#cleanup apt
apt-get clean && apt-get autoclean

# set dhcp to use mac - this is a little bit of a hack but I need this to be placed under the active nic settings
# also look in /etc/netplan for other config files
#sed -i 's/optional: true/dhcp-identifier: mac/g' /etc/netplan/50-cloud-init.yaml

# cleans out all of the cloud-init cache / logs - this is mainly cleaning out networking info
sudo cloud-init clean --logs

# Clear current machine-id which is also used by systemd-network to get DHCP leases
echo > /etc/machine-id
echo > /var/lib/dbus-machine-id

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w