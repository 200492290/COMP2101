#!/bin/bash

echo "Report for $(hostname)"
echo "==============="
echo "FQDN: $(hostname -f)"
OS=$(lsb_release -d | awk '{print $2, $3, $4}')
echo "Operating System name and version: $OS"
IP=$(ip addr | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)
echo "IP Address: $IP"
ROOT_FS=$(df -h / | awk 'NR==2 {print $4}')
echo "Root Filesystem Free Space: $ROOT_FS"
echo "==============="
