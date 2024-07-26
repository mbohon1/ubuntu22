Cảm ơn bạn đã cung cấp thông tin chi tiết. Nếu IP của VPS không thuộc dải 192.168.x.x, chúng ta cần xác định chính xác dải IP mà VPS đang sử dụng và điều chỉnh script cho phù hợp.

Để xác định dải IP hiện tại của VPS, bạn có thể sử dụng các lệnh sau:

```sh
ip addr show ens3
ip route
```

Kết quả của các lệnh này sẽ cho biết địa chỉ IP hiện tại và gateway của VPS. Sau khi có thông tin này, chúng ta có thể điều chỉnh script để chọn một địa chỉ IP ngẫu nhiên trong dải IP đúng.

Giả sử kết quả của `ip addr show ens3` là:

```
inet 10.0.0.5/24 brd 10.0.0.255 scope global dynamic ens3
```

Và kết quả của `ip route` là:

```
default via 10.0.0.1 dev ens3
10.0.0.0/24 dev ens3 proto kernel scope link src 10.0.0.5
```

Dựa trên thông tin này, chúng ta sẽ điều chỉnh script như sau:

1. **Cập nhật script với dải IP và gateway đúng**:
   - Cập nhật nội dung của tệp script (ví dụ: `random_ip_configure.sh`) như sau:
     ```sh
     #!/bin/bash

     # Dải IP để chọn ngẫu nhiên (ví dụ: 10.0.0.0/24)
     SUBNET="10.0.0"
     GATEWAY="10.0.0.1"

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
     ```

2. **Chạy lại script từ GitHub**:
   Trên máy chủ của bạn, chạy lại lệnh để tải và thực thi script đã cập nhật từ GitHub:

   ```sh
   wget -qO- https://raw.githubusercontent.com/mbohon1/ubuntu22/main/random_ip_configure.sh | sudo bash
   ```

Script này sẽ chọn một địa chỉ IP ngẫu nhiên trong dải IP đúng và áp dụng cấu hình mới.

Nếu bạn gặp bất kỳ vấn đề gì hoặc cần thêm trợ giúp, hãy cho tôi biết nhé!

Cảm ơn bạn đã cung cấp thông tin chi tiết. Nếu IP của VPS không thuộc dải 192.168.x.x, chúng ta cần xác định chính xác dải IP mà VPS đang sử dụng và điều chỉnh script cho phù hợp.

Để xác định dải IP hiện tại của VPS, bạn có thể sử dụng các lệnh sau:

ip addr show ens3
ip route

Kết quả của các lệnh này sẽ cho biết địa chỉ IP hiện tại và gateway của VPS. Sau khi có thông tin này, chúng ta có thể điều chỉnh script để chọn một địa chỉ IP ngẫu nhiên trong dải IP đúng.

Giả sử kết quả của ip addr show ens3 là:

inet 10.0.0.5/24 brd 10.0.0.255 scope global dynamic ens3

Và kết quả của ip route là:

default via 10.0.0.1 dev ens3
10.0.0.0/24 dev ens3 proto kernel scope link src 10.0.0.5

Dựa trên thông tin này, chúng ta sẽ điều chỉnh script như sau:

    Cập nhật script với dải IP và gateway đúng:
        Cập nhật nội dung của tệp script (ví dụ: random_ip_configure.sh) như sau:

        #!/bin/bash

        # Dải IP để chọn ngẫu nhiên (ví dụ: 10.0.0.0/24)
        SUBNET="10.0.0"
        GATEWAY="10.0.0.1"

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

