#!/bin/bash
echo "===1. 所有Nginx进程==="
ps aux | grep nginx | grep -v grep

echo "===2. 端口监听==="
netstat -tlnp | grep -E ':(80|443)'

echo "===3. 宝塔Nginx配置测试==="
/www/server/nginx/sbin/nginx -t 2>&1

echo "===4. 宝塔Nginx主配置include==="
grep "include" /www/server/nginx/conf/nginx.conf | grep -v "#"

echo "===5. 所有vhost配置文件==="
ls -la /www/server/panel/vhost/nginx/

echo "===6. 我们的配置内容==="
cat /www/server/panel/vhost/nginx/www.xyhuyart.com.conf

echo "===7. 本地测试HTTP==="
curl -s -o /dev/null -w "HTTP状态码:%{http_code}\n" -H "Host: www.xyhuyart.com" http://127.0.0.1

echo "===8. 本地测试HTTPS==="
curl -sk -o /dev/null -w "HTTPS状态码:%{http_code}\n" -H "Host: www.xyhuyart.com" https://127.0.0.1

echo "===9. 系统是否有其他Nginx==="
which nginx
ls -la /usr/sbin/nginx 2>/dev/null
ls -la /etc/nginx/ 2>/dev/null

echo "===完成==="
