#!/bin/bash

# 目标 IP
TARGET_IP="106.14.237.245"

echo "开始监控 IP: $TARGET_IP"

while true; do
    # ping 测试：发送 1 个包，超时时间设为 2 秒
    if ping -c 1 -W 2 "$TARGET_IP" > /dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 访问正常: $TARGET_IP 可以 Ping 通。"
        # 成功时每次间隔 5 秒再 ping，防止过于频繁请求
        sleep 5
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 访问异常: $TARGET_IP 无法 Ping 通！开始执行 API 请求更换 IP..."
        
        # Ping 不通时运行的 Curl 替换命令
        curl -X PATCH "https://api.aws.sb/ec2-instances/i-0f608127627abf1b1/ip-address?r=9kursev5jg" \
            --compressed \
            -H "x-auth-token: 364b8146ebd042ac8a5579464eaeb85a" \
            -H "x-region-name: ap-southeast-1" \
            -H "x-share-group-token: cea4ea1c333743f9be784b425ce8965a" \
            -H "content-type: application/json" \
            -H "accept: application/json, text/plain, */*" \
            -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36" \
            -H "origin: https://aws.sb" \
            -H "referer: https://aws.sb/" \
            -H "accept-encoding: gzip, deflate, br, zstd" \
            -H "accept-language: zh-CN,zh;q=0.9" \
            -d '{"gfw_blocked_check": true}' \
            -w "\nHTTP_CODE:%{http_code}\n"
            
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - API 请求执行完成。"
        
        # 考虑到更换 IP 或等待服务端响应需要时间，失败触发 API 后暂停较长时间（例如 60 秒）再恢复监控
        sleep 60
    fi
done
