#!/bin/bash

# 更新系统并安装 Dante
apt update -y && apt install -y dante-server

# 写入配置文件
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

# 启动服务并设置自启动
systemctl restart danted
systemctl enable danted

# 显示代理信息
echo "Socks5 代理已配置完成！以下是你的代理信息："
echo "IP地址: $(curl -s ifconfig.me)"
echo "端口: 1080"
echo "用户名: proxyuser"
echo "密码: proxy1234"
