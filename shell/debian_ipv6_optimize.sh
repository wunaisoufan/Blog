#!/bin/bash

# 函数：显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  1 - 更换为中科大纯 IPv6 源"
    echo "  2 - 更换为清华纯 IPv6 源"
    echo "  3 - 自动修复 IPv6 源"
    echo "  4 - 优化设置"
    echo "  5 - 优化 MTU 设置"
    echo "  6 - 启用邻居发现缓存"
    echo "  7 - 限制 IPv6 连接数"
    echo "  0 - 退出"
}

# 备份原有的 sources.list
function backup_sources() {
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
}

# 函数：更换源
function change_sources() {
    local mirror=$1
    case $mirror in
        ustc)
            echo "# 中科大镜像源" > /etc/apt/sources.list
            echo "deb https://ipv6.mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://ipv6.mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://ipv6.mirrors.ustc.edu.cn/debian-security/ bullseye-security main contrib non-free" >> /etc/apt/sources.list
            ;;
        tsinghua)
            echo "# 清华镜像源" > /etc/apt/sources.list
            echo "deb https://mirrors6.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://mirrors6.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://mirrors6.tuna.tsinghua.edu.cn/debian-security/ bullseye-security main contrib non-free" >> /etc/apt/sources.list
            ;;
        *)
            echo "未知的镜像源。"
            exit 1
            ;;
    esac

    # 调试输出，检查生成的 sources.list 内容
    echo "生成的 sources.list 内容："
    cat /etc/apt/sources.list
}

# 函数：自动修复
function auto_fix() {
    echo "正在检查和修复源..."
    apt update --fix-missing
    apt --fix-broken install
}

# 函数：优化设置
function optimize_settings() {
    echo "正在优化设置..."
    echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 0" >> /etc/sysctl.conf
    sysctl -p
}

# 函数：优化 MTU 设置
function optimize_mtu() {
    echo "正在优化 MTU 设置..."
    echo "net.ipv6.conf.all.mtu = 1280" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.mtu = 1280" >> /etc/sysctl.conf
    sysctl -p
}

# 函数：启用邻居发现缓存
function enable_neighbor_cache() {
    echo "正在启用邻居发现缓存..."
    echo "net.ipv6.conf.all.accept_ra = 2" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.accept_ra = 2" >> /etc/sysctl.conf
    sysctl -p
}

# 函数：限制 IPv6 连接数
function limit_connections() {
    echo "正在限制 IPv6 连接数..."
    echo "net.ipv6.conf.all.max_addresses = 1000" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.max_addresses = 1000" >> /etc/sysctl.conf
    sysctl -p
}

# 主程序
while true; do
    show_help
    read -p "请选择一个选项 (0-7): " choice
    case $choice in
        1)
            backup_sources
            change_sources ustc
            echo "Debian 源已成功更换为中科大纯 IPv6 镜像。"
            ;;
        2)
            backup_sources
            change_sources tsinghua
            echo "Debian 源已成功更换为清华纯 IPv6 镜像。"
            ;;
        3)
            auto_fix
            echo "自动修复完成。"
            ;;
        4)
            optimize_settings
            echo "优化设置完成。"
            ;;
        5)
            optimize_mtu
            echo "MTU 设置已优化。"
            ;;
        6)
            enable_neighbor_cache
            echo "邻居发现缓存已启用。"
            ;;
        7)
            limit_connections
            echo "IPv6 连接数已限制。"
            ;;
        0)
            echo "退出程序。"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择。"
            ;;
    esac
    apt update
done

