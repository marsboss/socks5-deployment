#!/bin/bash

# 更新系统并安装必要的软件包
apt update -y && apt install -y dante-server wget curl net-tools ufw

# 配置防火墙允许 1080 端口
ufw allow 1080/tcp
ufw allow 1080/udp
ufw reload

# 创建配置文件
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

# 创建日志文件并设置权限
mkdir -p /var/log
touch /var/log/danted.log
chmod 666 /var/log/danted.log

# 添加 proxyuser 用户并设置密码
useradd -r -s /usr/sbin/nologin proxyuser
echo "proxyuser:proxy1234" | chpasswd

# 启动并启用 danted 服务
systemctl restart danted
systemctl enable danted

# 检查服务状态
systemctl status danted > /root/danted_status.txt

# 获取服务器公网 IP 地址
IP=$(curl -s ifconfig.me)

# 保存配置信息
echo -e "🔥 Socks5 Server 配置成功！\n\nIP 地址：$IP\n端口：1080\n用户名：proxyuser\n密码：proxy1234" > /root/proxy_info.txt
echo -e "Socks5 Server 配置信息已保存到 /root/proxy_info.txt 文件中。"

# 显示配置信息
cat /root/proxy_info.txt
