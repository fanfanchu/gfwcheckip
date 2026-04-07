#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本 (例如: sudo bash install.sh)"
  exit 1
fi

INSTALL_DIR="/opt/aws-gfw-checker"
SERVICE_NAME="aws-gfw-checker"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_NAME="checker.sh"

echo "开始安装 AWS GFW Checker 服务..."

# 检查当前目录下是否存在 checker.sh
if [ ! -f "$SCRIPT_NAME" ]; then
    echo "错误: 当前目录下未找到 $SCRIPT_NAME 文件！"
    exit 1
fi

# 1. 创建安装目录并复制脚本
echo "1. 复制脚本到 $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_NAME" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# 2. 创建 systemd 服务文件
echo "2. 创建 systemd 服务文件 $SERVICE_FILE..."
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=AWS GFW IP Checker Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=/bin/bash $INSTALL_DIR/$SCRIPT_NAME
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=aws-gfw-checker

[Install]
WantedBy=multi-user.target
EOF

# 3. 重新加载 systemd 并启动服务
echo "3. 重新加载 systemd 配置..."
systemctl daemon-reload

echo "4. 设置服务开机自启并立即启动..."
systemctl enable "$SERVICE_NAME.service"
systemctl restart "$SERVICE_NAME.service"

echo "=========================================="
echo "安装和启动完成！"
echo "服务状态检查命令: systemctl status $SERVICE_NAME"
echo "查看运行日志命令: journalctl -u $SERVICE_NAME -f"
echo "=========================================="
