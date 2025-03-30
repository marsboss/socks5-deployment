#!/bin/bash

# 更新系统并安装必要的软件包
apt update -y && apt upgrade -y
apt install -y dante-server wget curl net-tools

# 创建日志目录和文件
mkdir -p /var/log
chmod 755 /var/log

# 创建日志文件
if [ ! -f /var/log/danted.log ]; then
    touch /var/log/danted.log
fi
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

# 创建用户
useradd -m proxyuser

# 设置用户密码
echo 'proxyuser:proxy1234' | chpasswd

# 重启Dante服务
systemctl restart danted
systemctl enable danted

# 检查Dante服务状态
systemctl status danted

# 检查端口监听
ss -ltnp | grep 1080

# 输出配置信息
IP=$(curl -s ifconfig.me)
echo "Socks5 ✔️"
echo "IP : $IP"
echo "Port : 1080"
echo "User : proxyuser"
echo "Password : proxy1234"
echo "✔️ 你的服务器已经配置完成"
echo "脚本配置完成" > /root/proxy_info.txt
