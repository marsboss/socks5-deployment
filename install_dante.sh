#!/bin/bash

# 更新系统并安装必要的软件包
apt update -y && apt upgrade -y
apt install -y dante-server wget curl net-tools

# 创建日志目录并设置权限
mkdir -p /var/log
touch /var/log/danted.log
chmod 777 /var/log/danted.log

# 检查用户是否已存在，避免重复创建
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

# 重启 Dante 服务并设置开机自动启动
systemctl restart danted
systemctl enable danted

# 显示配置信息
echo -e "Socks5代理已成功配置!\n"
echo "IP 地址：$(curl -s ifconfig.me)"
echo "端口：1080"
echo "用户名：proxyuser"
echo "密码：proxy1234"

# 将代理信息保存到文件
cat > /root/proxy_info.txt <<EOF
Socks5 代理信息：
IP 地址：$(curl -s ifconfig.me)
端口：1080
用户名：proxyuser
密码：proxy1234
EOF

# 检查服务状态
echo "正在检查服务状态..."
systemctl status danted

# 提示查看日志
echo -e "\n要查看日志信息，请使用以下命令："
echo "tail -f /var/log/danted.log"
