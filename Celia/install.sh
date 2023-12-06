#!/bin/sh

install_soft() {
    echo "正在安装请耐心等候"
    yum install -y wget curl vim net-tools  
}

install() {
    echo "正在安装请耐心等候"
    yum install -y java-1.8.0-openjdk.x86_64 mariadb-server

    # 检查是否安装成功
    if [ $? -eq 0 ]; then
        echo "软件安装成功"
        
        # 检查 java 命令是否存在
        if command -v java &> /dev/null; then
            echo "Java 已安装"
        else
            echo "Java 未安装，请检查安装过程中是否有错误"
            exit 1
        fi

        # 检查 mysql 命令是否存在
        if command -v mysql &> /dev/null; then
            echo "MySQL 已安装"
        else
            echo "MySQL 未安装，请检查安装过程中是否有错误"
            exit 1
        fi
    else
        echo "软件安装失败"
        exit 1
    fi
}

main_menu() {
    echo "========================"
    echo "请输入你要使用的功能的序号:                     "
    echo "1. 安装常用软件包"
    echo "2. 安装 JDK、MySQL 和下载 Tomcat"
    read -p "请输入对应功能的序号：" choose
    case $choose in 
        1)
        install_soft
        ;;
        2)
        install
        ;;
        *)
        echo "输入错误返回"
        main_menu
        ;;
    esac
}

# 主程序从这里开始
if [[ -f /etc/redhat-release ]]; then
    release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
    release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
    release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="Centos"
else 
    echo "不支持你当前系统，请使用 Ubuntu、Debian、Centos 系统"
    exit 1
fi

# 开始循环
main_menu
