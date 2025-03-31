#!/bin/bash
# 更新系统并安装必要组件
apt update && apt install -y dante-server wget curl net-tools

# 创建日志文件目录并修改权限
mkdir -p /var/log
touch /var/log/danted.log
chmod 777 /var/log/danted.log

# 创建配置文件
cat > /etc/danted.conf << EOF
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

# 创建一个新的用户用于验证
useradd -m -s /bin/false proxyuser
echo "proxyuser:proxy1234" | chpasswd

# 启动并启用 Dante 服务
systemctl restart danted
systemctl enable danted

# 输出配置信息
echo -e "\nSocks5 🧦 服务安装成功！\n"
echo "IP地址: $(curl -s ifconfig.me)"
echo "端口号: 1080"
echo "用户名: proxyuser"
echo "密码: proxy1234"
