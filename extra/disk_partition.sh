#!/bin/bash

echo "Bump! I'm your first-boot script."

echo "Fix unmet dependency of apt by removing shim-signed"
apt-get update
apt-get remove -y shim-signed
apt-get -y autoremove
apt-get -y install vim

echo "Configure grub with no sleep mode"
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&acpi=off apm=off /' /etc/default/grub

echo "Configure hostname"
sed -i 's/^ubuntu/psk3-cso-host1/'  /etc/hostname
hostname psk3-cso-host1

echo "Configure sshd config"
sed -i 's/^PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
service ssh restart

echo "Disk partitioning"
swapoff /dev/sda3
parted -s /dev/sda rm 3
parted -s /dev/sda resizepart 2 Yes 448000
parted -s /dev/sda 'mkpart sda3 linux-swap(v1) 448000 -1'
python /root/extra/mkswap.py
parted -s -a optimal /dev/sdb mklabel gpt -- mkpart primary ext4 0% 100%
mkdir /RAID
printf '\n#Mount /dev/sdb1 as /RAID\n' >> /etc/fstab
printf '/dev/sdb1       /RAID           ext4    errors=remount-ro       0       0\n' >> /etc/fstab
mount -a

echo "Install openssh-client build-essential"
apt-get -y install openssh-client build-essential checkinstall

echo "Install libffi-dev libxslt-dev libssl-dev"
apt-get -y install libffi-dev libxslt-dev libssl-dev

echo "Upgrade python to 2.7.14"
mv /root/extra/Python-2.7.14.tgz /usr/src/
tar -xzf /usr/src/Python-2.7.14.tgz
cd /usr/src
./configure --enable-optimizations
make install
cd /root/

echo "Install python-dev python-pip"
apt-get -y install python-dev python-pip

echo "Install Ansbile"
pip install --yes -U setuptools
pip install ansible junos-eznc
ansible-galaxy install Juniper.junos

# Delete me
rm $0
