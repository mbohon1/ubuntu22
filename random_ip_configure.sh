#!/bin/bash

# Lấy thông tin mạng hiện tại
CURRENT_IP_INFO=$(ip addr show ens3 | grep 'inet ' | awk '{print $2}')
CURRENT_IP=${CURRENT_IP_INFO%/*}
SUBNET=$(echo $CURRENT_IP | cut -d. -f1-3)
GATEWAY=$(ip route | grep default | awk '{print $3}')

echo "Current IP: ${CURRENT_IP}"
echo "Subnet: ${SUBNET}"
echo "Gateway: ${GATEWAY}"

# Hàm kiểm tra xem IP có đang được sử dụng hay không
function is_ip_in_use {
    ping -c 1 -W 1 $1 > /dev/null 2>&1
    return $?
}

# Tìm một địa chỉ IP ngẫu nhiên không sử dụng
while true; do
    RANDOM_IP="$SUBNET.$((RANDOM % 254 + 1))"
    echo "Testing IP: ${RANDOM_IP}"
    if ! is_ip_in_use $RANDOM_IP; then
        break
    fi
done

echo "Selected IP: ${RANDOM_IP}"

# Lấy địa chỉ MAC hiện tại của ens3
MAC_ADDRESS=$(ip link show ens3 | awk '/ether/ {print $2}')
echo "MAC Address: ${MAC_ADDRESS}"

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

echo "New netplan configuration created."

# Áp dụng cấu hình netplan mới và kiểm tra kết nối mạng trong 10 giây
netplan apply --config-file=/etc/netplan/50-cloud-init-new.yaml

echo "Testing new network configuration for 10 seconds..."
sleep 10

# Kiểm tra kết nối mạng bằng cách ping gateway
if ping -c 1 ${GATEWAY} &> /dev/null; then
    echo "New network configuration is working. Applying permanently."
    mv /etc/netplan/50-cloud-init-new.yaml /etc/netplan/50-cloud-init.yaml
    netplan apply
    echo "Network configuration applied successfully with IP: ${RANDOM_IP}"
else
    echo "Failed to apply new network configuration. Reverting to original configuration."
    rm /etc/netplan/50-cloud-init-new.yaml
    netplan apply --config-file=/etc/netplan/50-cloud-init.yaml.bak
fi

echo "Script execution completed."
