#!/bin/sh

install_soft() {
    sleep 3
    
    echo "正在安装请耐心等候"
    yum install -y wget curl vim net-tools unzip tar zip
}

install() {
    sleep 3
    
    echo "开始安装"
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

        # 启动 MariaDB 服务
        systemctl start mariadb
        if systemctl is-active --quiet mariadb; then
            echo "MySQL 服务已启动"
            
            # 设置 MariaDB 开机自启动
            systemctl enable mariadb
            echo "MySQL 设置为开机自启动"
        else
            echo "MySQL 服务未启动，请检查安装过程中是否有错误"
            exit 1
        fi
    else
        echo "软件安装失败"
        exit 1
    fi
}

tomcat() {
    sleep 3
    echo "开始下载 Tomcat"
    wget -O tomcat.zip https://cloud.7boe.top/d/HKOSS/%E8%BD%AF%E4%BB%B6%E5%8C%85/apache-tomcat-8.5.96.zip?sign=PZ9SMydzs8HhEzvmdjFzs_yPJBO85yROlhMdqNmSYCA=:0
    
    # 解压 Tomcat
    unzip tomcat.zip
    echo "Tomcat 下载并解压完成"
    mv apache-tomcat-8.5.96/ tomcat8
    # 授权执行权限
    chmod +x /root/tomcat8/bin/*.sh

    # 创建 systemd 服务单元文件
    cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description=tomcat
After=network.target

[Service]
Type=forking
ExecStart=/root/tomcat8/bin/startup.sh
ExecReload=/root/tomcat8/bin/startup.sh && /root/tomcat8/bin/shutdown.sh
ExecStop=/root/tomcat8/bin/shutdown.sh
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    #重载服务
    systemctl daemon-reload
    # 启动 Tomcat 服务
    systemctl start tomcat
    if systemctl is-active --quiet tomcat; then
        echo "Tomcat 服务已启动"

        # 设置 Tomcat 开机自启动
        systemctl enable tomcat
        echo "Tomcat 设置为开机自启动"
    else
        echo "Tomcat 服务未启动，请检查安装过程中是否有错误"
        exit 1
    fi
}

main_menu() {
    echo "========================"
    echo "请输入你要使用的功能的序号:                     "
    echo "1. 安装常用软件包"
    echo "2. 安装 JDK、MySQL"
    echo "3. 下载并且安装 Tomcat"
    read -p "请输入对应功能的序号：" choose
    case $choose in 
        1)
        install_soft
        ;;
        2)
        install
        ;;
        3)
        tomcat
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
