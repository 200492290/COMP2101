#!/bin/bash

# Install necessary packages
sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Create a network bridge
sudo brctl addbr br0
sudo ip addr add 192.168.100.1/24 dev br0
sudo ip link set br0 up

# Download Ubuntu 20.04 server image
# wget https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso

# Create a virtual machine
sudo virt-install \
--name COMP2101-S22 \
--ram 2048 \
--disk path=/var/lib/libvirt/images/COMP2101-S22.qcow2,size=10 \
--vcpus 1 \
--os-type linux \
--os-variant ubuntu20.04 \
--network bridge=br0 \
--cdrom ubuntu-20.04.5-live-server-amd64.iso \
--graphics none \
--console pty,target_type=serial

# Wait for the virtual machine to finish installing
echo "Waiting for virtual machine to start..."
while ! ping -c1 192.168.100.10 &>/dev/null; do sleep 1; done

# Add or update the entry in /etc/hosts for hostname COMP2101-S22 with the virtual machine's IP address
container_ip=$(sudo virsh domifaddr COMP2101-S22 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
if ! grep -q "COMP2101-S22" /etc/hosts; then
    echo "$container_ip COMP2101-S22" | sudo tee -a /etc/hosts > /dev/null
else
    sudo sed -i "/COMP2101-S22/ s/.*/$container_ip COMP2101-S22/" /etc/hosts
fi

# Install Apache2 in the virtual machine
ssh-keygen -R "COMP2101-S22"
sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@COMP2101-S22 sudo apt-get update
sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@COMP2101-S22 sudo apt-get install -y apache2

# Retrieve the default web page from the virtual machine's web service
if curl http://COMP2101-S22 &> /dev/null; then
    echo "Virtual Web Server is up and running!"
else
    echo "Failed to retrieve default web page."
fi
