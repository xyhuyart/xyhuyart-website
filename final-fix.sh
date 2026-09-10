#!/bin/bash
echo "===1. 备份默认站点==="
cp /www/server/panel/vhost/nginx/0.default.conf /www/server/panel/vhost/nginx/0.default.conf.bak

echo "===2. 修改默认站点，去掉443和ssl配置==="
sed -i '/443/s/^/#/' /www/server/panel/vhost/nginx/0.default.conf
sed -i '/ssl_/s/^/#/' /www/server/panel/vhost/nginx/0.default.conf

echo "===3. 确保我们的站点配置正确==="
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

echo "===4. 测试配置==="
/www/server/nginx/sbin/nginx -t 2>&1

echo "===5. 重启Nginx==="
/etc/init.d/nginx restart
sleep 2

echo "===6. 检查端口==="
netstat -tlnp | grep -E ':(80|443)'

echo "===7. 测试HTTPS==="
curl -sk -o /dev/null -w "HTTPS状态码:%{http_code}\n" https://www.xyhuyart.com

echo "===完成==="
