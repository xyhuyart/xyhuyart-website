#!/bin/bash
echo "===1. 备份并清理所有vhost配置==="
mkdir -p /www/server/panel/vhost/nginx/backup2
mv /www/server/panel/vhost/nginx/*.conf /www/server/panel/vhost/nginx/backup2/ 2>/dev/null
echo "已清理所有配置"

echo "===2. 写入我们的站点配置==="
cat > /www/server/panel/vhost/nginx/www.xyhuyart.com.conf << 'EOF'
server {
    listen 80;
    server_name www.xyhuyart.com;
    return 301 https://www.xyhuyart.com$request_uri;
}
server {
    listen 443 ssl;
    server_name www.xyhuyart.com;
    root /www/wwwroot/www.xyhuyart.com;
    index index.html;
    ssl_certificate /etc/letsencrypt/live/www.xyhuyart.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.xyhuyart.com/privkey.pem;
    location / { try_files $uri $uri/ =404; }
}
EOF
echo "配置已写入"

echo "===3. 测试配置==="
/www/server/nginx/sbin/nginx -t 2>&1

echo "===4. 重启Nginx==="
/etc/init.d/nginx restart
sleep 2

echo "===5. 检查端口==="
netstat -tlnp | grep -E ':(80|443)'

echo "===6. 本地测试==="
curl -sk -o /dev/null -w "HTTPS状态码:%{http_code}\n" -H "Host: www.xyhuyart.com" https://127.0.0.1

echo "===完成==="
