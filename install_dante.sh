#!/bin/bash

# 更新系统并安装必要的软件包
apt update && apt upgrade -y
apt install -y dante-server curl wget net-tools

# 创建日志目录并设置权限
mkdir -p /var/log
chmod 755 /var/log
touch /var/log/danted.log
chmod 666 /var/log/danted.log

# 创建用户
useradd -m proxyuser
echo "proxyuser:proxy1234" | chpasswd

# 写入配置文件
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

# 启动服务并设置开机启动
systemctl restart danted
systemctl enable danted

# 输出配置信息
echo "Socks5配置完成"
echo "IP地址: $(curl -s ifconfig.me)"
echo "端口: 1080"
echo "用户名: proxyuser"
echo "密码: proxy1234"
