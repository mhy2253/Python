#!/bin/bash

# 颜色定义
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
NC='\e[0m' # 恢复默认颜色

# 输出带颜色的消息
log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_failure() {
    echo -e "${RED}[FAILURE] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# FileBrowser 安装和配置脚本

# 检测是否以 root 用户运行
if [ "$EUID" -ne 0 ]; then
    log_failure "请以 root 用户运行此脚本。"
    exit 1
fi

# 检测是否已安装 curl 和 bash
log_warning "检测系统依赖..."
for cmd in curl bash; do
    if ! command -v $cmd &> /dev/null; then
        log_warning "$cmd 未安装，正在尝试安装..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y $cmd
        elif command -v yum &> /dev/null; then
            yum install -y $cmd
        elif command -v dnf &> /dev/null; then
            dnf install -y $cmd
        else
            log_failure "无法自动安装 $cmd，请手动安装后重试。"
            exit 1
        fi
        if [ $? -eq 0 ]; then
            log_success "$cmd 安装成功。"
        else
            log_failure "$cmd 安装失败。"
            exit 1
        fi
    fi
done
log_success "系统依赖检测完成。"

# 安装 FileBrowser
log_warning "正在安装 FileBrowser..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
if [ $? -ne 0 ]; then
    log_failure "FileBrowser 安装失败，请检查网络连接或脚本地址。"
    exit 1
fi
log_success "FileBrowser 安装完成。"

# 检查数据库文件是否已存在
if [ -f "/etc/filebrowser/filebrowser.db" ]; then
    log_warning "检测到已存在的配置文件：/etc/filebrowser/filebrowser.db"
    read -p "是否覆盖现有配置？(y/n，默认使用现有配置): " overwrite
    overwrite=${overwrite:-n}
    if [[ "$overwrite" == "y" || "$overwrite" == "Y" ]]; then
        log_warning "正在删除旧配置文件..."
        rm -f /etc/filebrowser/filebrowser.db
        log_success "旧配置文件已删除。"
    else
        log_success "使用现有配置文件。"
    fi
fi

# 初始化配置数据库（如果文件不存在）
if [ ! -f "/etc/filebrowser/filebrowser.db" ]; then
    log_warning "正在创建配置数据库..."
    mkdir -p /etc/filebrowser
    filebrowser -d /etc/filebrowser/filebrowser.db config init
    if [ $? -ne 0 ]; then
        log_failure "配置数据库创建失败。"
        exit 1
    fi
    log_success "配置数据库创建完成。"
fi

# 设置监听地址
read -p "请输入 FileBrowser 监听的 IP 地址（默认：0.0.0.0）： " listen_address
listen_address=${listen_address:-0.0.0.0}
filebrowser -d /etc/filebrowser/filebrowser.db config set --address "$listen_address"
log_success "监听地址设置为：$listen_address"

# 设置监听端口
read -p "请输入 FileBrowser 监听的端口号（默认：8088）： " listen_port
listen_port=${listen_port:-8088}
filebrowser -d /etc/filebrowser/filebrowser.db config set --port "$listen_port"
log_success "监听端口设置为：$listen_port"

# 设置语言环境为中文
log_warning "设置语言环境为中文..."
filebrowser -d /etc/filebrowser/filebrowser.db config set --locale zh-cn
log_success "语言环境设置为中文。"

# 设置日志位置
log_warning "设置日志文件位置..."
filebrowser -d /etc/filebrowser/filebrowser.db config set --log /var/log/filebrowser.log
log_success "日志文件位置设置为：/var/log/filebrowser.log"

# 添加管理员用户
read -p "请输入管理员用户名（默认：admin）： " admin_user
admin_user=${admin_user:-admin}
read -p "请输入管理员密码（默认：password）： " admin_password
admin_password=${admin_password:-password}
filebrowser -d /etc/filebrowser/filebrowser.db users add "$admin_user" "$admin_password" --perm.admin
if [ $? -ne 0 ]; then
    log_failure "管理员用户添加失败。"
    exit 1
fi
log_success "管理员用户添加完成，用户名：$admin_user，密码：$admin_password"

# 创建 systemd 服务文件
log_warning "配置 systemd 服务..."
cat <<EOF > /etc/systemd/system/filebrowser.service
[Unit]
Description=FileBrowser
After=network.target

[Service]
ExecStart=$(which filebrowser) -d /etc/filebrowser/filebrowser.db
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 配置
systemctl daemon-reload

# 启用并启动 FileBrowser 服务
systemctl enable filebrowser
systemctl start filebrowser

if [ $? -ne 0 ]; then
    log_failure "FileBrowser 服务启动失败，请检查配置。"
    exit 1
fi
log_success "FileBrowser 服务已启动并设置为开机自启动。"

# 输出访问信息
echo "============================================"
log_success "FileBrowser 安装和配置完成！"
log_success "访问地址：http://$listen_address:$listen_port"
log_success "用户名：$admin_user"
log_success "密码：$admin_password"
echo "============================================"

exit 0