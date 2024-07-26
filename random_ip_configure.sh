#!/bin/bash

# Dải IP để chọn ngẫu nhiên (ví dụ: 192.168.1.0/24)
SUBNET="192.168.1"
RANDOM_IP="$SUBNET.$((RANDOM % 254 + 1))"

# Cấu hình netplan với địa chỉ IP ngẫu nhiên
cat <<EOF > /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    ens3:
      addresses:
        - ${RANDOM_IP}/24
      dhcp4: false
      gateway4: ${SUBNET}.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      match:
        macaddress: fa:16:3e:af:61:43
      set-name: ens3
EOF

# Áp dụng cấu hình netplan
netplan apply

echo "Network configuration applied successfully with IP: ${RANDOM_IP}"
