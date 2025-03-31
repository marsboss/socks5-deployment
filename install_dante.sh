#!/bin/bash

# 更新系统并安装必要的软件包
apt update -y && apt upgrade -y
apt install -y dante-server wget curl net-tools

# 创建日志目录并设置权限
mkdir -p /var/log
touch /var/log/danted.log
chmod 777 /var/log/danted.log

# 创建用户（如果不存在）
if ! id "proxyuser" &>/dev/null; then
    useradd -m -s /usr/sbin/nologin proxyuser
    echo "proxyuser:proxy1234" | chpasswd
fi

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

# 设置 danted 服务配置
systemctl daemon-reload
systemctl enable danted

# 启动并重启服务
systemctl restart danted

# 检查服务状态
systemctl status danted

# 保存代理信息到文件
echo "Socks5 代理已成功配置!" > /root/proxy_info.txt
echo "IP 地址：$(curl -s ifconfig.me)" >> /root/proxy_info.txt
echo "端口：1080" >> /root/proxy_info.txt
echo "用户名：proxyuser" >> /root/proxy_info.txt
echo "密码：proxy1234" >> /root/proxy_info.txt

# 显示配置信息
cat /root/proxy_info.txt
