#!/bin/bash
# 煊叶书画院网站一键部署脚本
# 自动安装 Caddy（自带 HTTPS）+ 部署网站

set -e

echo "========================================="
echo "  煊叶书画院网站一键部署"
echo "========================================="

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 用户运行，或加 sudo"
  exit 1
fi

# 1. 安装 Caddy
echo "[1/5] 安装 Caddy 服务器..."
if command -v apt &> /dev/null; then
    apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update
    apt install -y caddy
elif command -v yum &> /dev/null; then
    yum install -y yum-plugin-copr
    yum copr enable -y @caddy/caddy
    yum install -y caddy
else
    echo "不支持的系统，请手动安装 Caddy"
    exit 1
fi

# 2. 创建网站目录
echo "[2/5] 创建网站目录..."
mkdir -p /var/www/xyhuyart

# 3. 下载网站文件
echo "[3/5] 下载网站文件..."
curl -sL -o /var/www/xyhuyart/index.html https://raw.githubusercontent.com/xyhuyart/xyhuyart-website/main/index.html
echo "  网站文件已下载"

# 4. 配置 Caddy
echo "[4/5] 配置 Caddy..."
cat > /etc/caddy/Caddyfile <<'EOF'
www.xyhuyart.com {
    root * /var/www/xyhuyart
    file_server
    encode gzip
}

xyhuyart.com {
    redir https://www.xyhuyart.com{uri}
}
EOF

# 5. 启动 Caddy
echo "[5/5] 启动 Caddy 服务..."
systemctl enable caddy
systemctl restart caddy

# 放行防火墙
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

echo ""
echo "========================================="
echo "  部署完成！"
echo "  网站地址：https://www.xyhuyart.com"
echo "  （HTTPS 证书自动签发中，约 1-2 分钟生效）"
echo "========================================="
