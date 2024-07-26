#!/bin/bash

# Dải IP để chọn ngẫu nhiên (ví dụ: 192.168.1.0/24)
SUBNET="192.168.1"
GATEWAY="${SUBNET}.1"

# Hàm kiểm tra xem IP có đang được sử dụng hay không
function is_ip_in_use {
    ping -c 1 -W 1 $1 > /dev/null 2>&1
    return $?
}

# Tìm một địa chỉ IP ngẫu nhiên không sử dụng
while true; do
    RANDOM_IP="$SUBNET.$((RANDOM % 254 + 1))"
    if ! is_ip_in_use $RANDOM_IP; then
        break
    fi
done

# Lấy địa chỉ MAC hiện tại của ens3
MAC_ADDRESS=$(ip link show ens3 | awk '/ether/ {print $2}')

# Tạo tệp cấu hình netplan mới
cat <<EOF > /etc/netplan/50-cloud-init-new.yaml
network:
  version: 2
  ethernets:
    ens3:
      addresses:
        - ${RANDOM_IP}/24
      dhcp4: false
      routes:
        - to: default
          via: ${GATEWAY}
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      match:
        macaddress: ${MAC_ADDRESS}
      set-name: ens3
EOF

# Áp dụng cấu hình netplan mới và kiểm tra kết nối mạng
netplan try --config-file=/etc/netplan/50-cloud-init-new.yaml

if [ $? -eq 0 ]; then
    mv /etc/netplan/50-cloud-init-new.yaml /etc/netplan/50-cloud-init.yaml
    netplan apply
    echo "Network configuration applied successfully with IP: ${RANDOM_IP}"
else
    echo "Failed to apply new network configuration. Reverting to original configuration."
    rm /etc/netplan/50-cloud-init-new.yaml
    netplan apply
fi
