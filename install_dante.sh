#!/bin/bash

# 更新系统并安装必要的软件
apt update -y && apt upgrade -y
apt install -y dante-server curl wget net-tools

# 创建日志目录
mkdir -p /var/log
mkdir -p /var/log/danted.log
chmod 755 /var/log
chmod 666 /var/log/danted.log

# 创建用户
useradd -m proxyuser
echo "proxyuser:proxy1234" | chpasswd

# 配置文件路径
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

# 确认配置文件无语法错误
danted -f /etc/danted.conf -t

# 重新启动 danted 服务
systemctl restart danted
systemctl enable danted

# 检查 danted 状态
systemctl status danted

# 保存配置信息到文件
echo -e "Socks5 ✔\nIP: $(curl -s ifconfig.me)\nPort: 1080\nUser: proxyuser\nPassword: proxy1234" > /root/proxy_info.txt
