#!/bin/bash
# 停止系统 Nginx
systemctl stop nginx 2>/dev/null
systemctl disable nginx 2>/dev/null
echo "系统Nginx已停止"

# 强制停止所有 Nginx 进程
killall -9 nginx 2>/dev/null
sleep 2
echo "所有Nginx进程已停止"

# 启动宝塔 Nginx
/etc/init.d/nginx start
sleep 3
echo "宝塔Nginx已启动"

# 检查端口
netstat -tlnp | grep -E ':(80|443)'
echo "全部完成"
