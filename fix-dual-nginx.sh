#!/bin/bash
echo "===1. 停止并禁用系统Nginx==="
systemctl stop nginx 2>/dev/null
systemctl disable nginx 2>/dev/null
echo "系统Nginx已停止"

echo "===2. 停止所有Nginx进程==="
killall nginx 2>/dev/null
sleep 2

echo "===3. 确认没有Nginx进程==="
ps aux | grep nginx | grep -v grep || echo "无Nginx进程"

echo "===4. 启动宝塔Nginx==="
/etc/init.d/nginx start
sleep 2

echo "===5. 检查端口==="
netstat -tlnp | grep -E ':(80|443)'

echo "===6. 测试HTTPS==="
curl -sk -o /dev/null -w "HTTPS状态码:%{http_code}\n" https://www.xyhuyart.com

echo "===完成==="
