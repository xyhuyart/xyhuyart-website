#!/bin/bash
# 煊叶书画院网站部署脚本（宝塔/Nginx 环境）
set -e

echo "========================================="
echo "  煊叶书画院网站部署（宝塔环境）"
echo "========================================="

# 1. 停止 Caddy（之前装的，现在不用了）
echo "[1/7] 停止 Caddy..."
systemctl stop caddy 2>/dev/null || true
systemctl disable caddy 2>/dev/null || true

# 2. 创建网站目录
echo "[2/7] 创建网站目录..."
mkdir -p /www/wwwroot/www.xyhuyart.com

# 3. 下载网站文件
echo "[3/7] 下载网站文件..."
curl -sL -o /www/wwwroot/www.xyhuyart.com/index.html https://raw.githubusercontent.com/xyhuyart/xyhuyart-website/main/index.html
chown -R www:www /www/wwwroot/www.xyhuyart.com

# 4. 创建 Nginx 配置（HTTP）
echo "[4/7] 配置 Nginx..."
cat > /www/server/panel/vhost/nginx/www.xyhuyart.com.conf <<'EOF'
server {
    listen 80;
    server_name www.xyhuyart.com xyhuyart.com;
    root /www/wwwroot/www.xyhuyart.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# 5. 重启 Nginx
echo "[5/7] 重启 Nginx..."
/etc/init.d/nginx restart
sleep 2

# 6. 安装 certbot 并申请 SSL 证书
echo "[6/7] 申请 HTTPS 证书..."
apt install -y certbot python3-certbot-nginx 2>/dev/null || true
certbot --nginx -d www.xyhuyart.com -d xyhuyart.com --non-interactive --agree-tos -m xuanyehuayu@xyhyart.cn --redirect 2>/dev/null || {
    echo "  证书申请遇到问题，将使用 HTTP 模式，后续可在宝塔面板手动申请 SSL"
}

# 7. 最终重启 Nginx
echo "[7/7] 最终重启 Nginx..."
/etc/init.d/nginx restart

echo ""
echo "========================================="
echo "  部署完成！"
echo "  网站地址：https://www.xyhuyart.com"
echo "========================================="
