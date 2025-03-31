#!/bin/bash

# 更新系统并安装必要的软件包
apt update && apt install -y dante-server wget curl net-tools

# 确保日志目录存在并设置权限
mkdir -p /var/log
touch /var/log/danted.log
chmod 666 /var/log/danted.log

# 确保配置文件目录存在
mkdir -p /etc

# 创建并写入配置文件
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

# 添加代理用户
useradd -M proxyuser
echo "proxyuser:proxy1234" | chpasswd

# 设置服务开机自启并重启服务
systemctl enable danted
systemctl restart danted

# 输出代理信息到文件
echo "Socks5 配置信息已成功部署！" > /root/proxy_info.txt
echo "IP 地址：$(curl -s ifconfig.me)" >> /root/proxy_info.txt
echo "端口：1080" >> /root/proxy_info.txt
echo "用户名：proxyuser" >> /root/proxy_info.txt
echo "密码：proxy1234" >> /root/proxy_info.txt

# 显示成功信息
echo "Socks5 代理配置完成。"
echo "配置文件已保存到 /root/proxy_info.txt"
