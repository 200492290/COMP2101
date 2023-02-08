#!/bin/bash

# Fully qualified domain name
FQDN=$(hostname -f)
echo "FQDN: $FQDN"

# OS information
echo "Host Information:"
hostnamectl

# IP information
echo "IP Addresses:"
ip -o -4 addr | awk '{print $4}'

# File system information
echo "Root Filesystem Status:"
df /dev/sr1
