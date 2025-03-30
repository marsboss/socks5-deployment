#!/bin/bash

# 更新系统并安装必要的软件包
apt update && apt upgrade -y
apt install -y wget curl net-tools ufw dante-server

# 创建日志目录
mkdir -p /var/log
touch /var/log/danted.log
chmod 755 /var/log
chmod 666 /var/log/danted.log

# 写入配置文件
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080
external: eth0
socksmethod: username
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}

sockspass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    socksmethod: username
    log: connect disconnect
}
EOF

# 创建用户并设置密码
useradd -m proxyuser
echo "proxyuser:proxy1234" | chpasswd

# 启用并启动 danted 服务
systemctl restart danted
systemctl enable danted

# 配置防火墙
ufw allow 1080/tcp
ufw allow 1080/udp
ufw allow OpenSSH
ufw --force enable

# 显示配置信息
echo -e "\n\n====================================="
echo "Dante Socks5 配置完成！"
echo "服务器IP地址: $(curl -s ifconfig.me)"
echo "端口号: 1080"
echo "用户名: proxyuser"
echo "密码: proxy1234"
echo -e "=====================================\n\n"

# 保存配置信息到文件
echo -e "IP: $(curl -s ifconfig.me)\nPort: 1080\nUser: proxyuser\nPassword: proxy1234" > /root/proxy_info.txt

echo "安装完成。配置信息保存在 /root/proxy_info.txt"
