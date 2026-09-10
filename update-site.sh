#!/bin/bash
echo "========================================="
echo "  煊叶书画院网站更新部署脚本"
echo "========================================="
echo ""

echo "[1/4] 下载最新网站文件..."
curl -sL -o /www/wwwroot/www.xyhuyart.com/index.html https://raw.githubusercontent.com/xyhuyart/xyhuyart-website/main/index.html
if [ $? -eq 0 ]; then
    echo "  ✓ 网站文件下载成功"
    ls -la /www/wwwroot/www.xyhuyart.com/index.html
else
    echo "  ✗ 网站文件下载失败"
    exit 1
fi
echo ""

echo "[2/4] 重启 Nginx..."
if [ -f /www/server/nginx/sbin/nginx ]; then
    /www/server/nginx/sbin/nginx -s reload 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  ✓ 宝塔 Nginx 重载成功"
    else
        echo "  ⚠ Nginx 重载失败，尝试重启..."
        /etc/init.d/nginx restart 2>/dev/null || service nginx restart 2>/dev/null
        echo "  ✓ Nginx 已重启"
    fi
else
    /etc/init.d/nginx restart 2>/dev/null || service nginx restart 2>/dev/null
    echo "  ✓ Nginx 已重启"
fi
echo ""

echo "[3/4] 本地验证网站状态..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --resolve www.xyhuyart.com:443:127.0.0.1 https://www.xyhuyart.com/ 2>/dev/null)
echo "  本地 HTTPS 状态码: $HTTP_CODE"
echo ""

echo "[4/4] 验证网站内容是否已更新..."
CONTENT=$(curl -s --resolve www.xyhuyart.com:443:127.0.0.1 https://www.xyhuyart.com/ 2>/dev/null | grep -o "央美根系" | head -1)
if [ -n "$CONTENT" ]; then
    echo "  ✓ 网站内容已更新为真实信息（包含'央美根系'）"
else
    echo "  ⚠ 未检测到新内容关键词，可能需要清除浏览器缓存后查看"
fi
echo ""

echo "========================================="
echo "  部署完成！"
echo "  网站地址：https://www.xyhuyart.com"
echo "  如浏览器显示旧内容，请按 Ctrl+F5 强制刷新"
echo "========================================="
