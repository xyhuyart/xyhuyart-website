#!/bin/bash
echo "===1. 停止所有Nginx==="
/etc/init.d/nginx stop
killall nginx 2>/dev/null
sleep 1

echo "===2. 清理旧配置==="
mkdir -p /www/server/panel/vhost/nginx/backup
mv /www/server/panel/vhost/nginx/*xyhuyart* /www/server/panel/vhost/nginx/backup/ 2>/dev/null

echo "===3. 确保网站文件存在==="
mkdir -p /www/wwwroot/www.xyhuyart.com
curl -sL -o /www/wwwroot/www.xyhuyart.com/index.html https://raw.githubusercontent.com/xyhuyart/xyhuyart-website/main/index.html
chown -R www:www /www/wwwroot/www.xyhuyart.com

echo "===4. 检查证书并配置==="
if [ -f /etc/letsencrypt/live/www.xyhuyart.com/fullchain.pem ]; then
    echo "证书存在，配置HTTPS"
    cat > /www/server/panel/vhost/nginx/www.xyhuyart.com.conf << 'EOF'
server { listen 80; server_name www.xyhuyart.com; return 301 https://www.xyhuyart.com$request_uri; }
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
else
    echo "证书不存在，只配置HTTP"
    cat > /www/server/panel/vhost/nginx/www.xyhuyart.com.conf << 'EOF'
server {
    listen 80;
    server_name www.xyhuyart.com;
    root /www/wwwroot/www.xyhuyart.com;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
EOF
fi

echo "===5. 测试配置==="
/www/server/nginx/sbin/nginx -t 2>&1

echo "===6. 启动Nginx==="
/etc/init.d/nginx start
sleep 2

echo "===7. 检查端口==="
netstat -tlnp | grep -E ':(80|443)'

echo "===8. 本地测试HTTP==="
curl -s -o /dev/null -w "HTTP状态码:%{http_code}\n" -H "Host: www.xyhuyart.com" http://127.0.0.1

echo "===9. 本地测试HTTPS==="
curl -sk -o /dev/null -w "HTTPS状态码:%{http_code}\n" -H "Host: www.xyhuyart.com" https://127.0.0.1

echo "===全部完成==="
