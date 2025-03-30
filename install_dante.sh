#!/bin/bash

# 更新系统并安装必要工具
apt update -y && apt install -y dante-server wget curl

# 写入 Dante 配置文件
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080
external: eth0
method: username
user.notprivileged: nobody

client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect disconnect
}
pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  protocol: tcp udp
  method: username
  log: connect disconnect
}
EOF

# 创建用户并设置密码
useradd -r proxyuser
echo 'proxyuser:proxy1234' | chpasswd

# 开启并自动启动 Dante 服务
systemctl restart danted
systemctl enable danted

# 显示代理信息并保存到文件
IP=$(curl -s ifconfig.me)
echo -e "Socks5 代理配置完成！\nIP地址: $IP\n端口: 1080\n用户名: proxyuser\n密码: proxy1234" | tee /root/proxy_info.txt

echo "✅ 配置完成！你的代理信息已保存到 /root/proxy_info.txt"
