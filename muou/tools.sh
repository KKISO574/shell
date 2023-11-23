#!/bin/bash
#auther:muou
#version:0.0.1
#create_date:2023-11-21
#update:

#彩色
red(){
	echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
	echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
	echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
	echo -e "\033[34m\033[01m$1\033[0m"
}


#version：0.0.1
#需求：
#做一个工具箱
#可以一键安装一些服务
#可以一键校对时间

#主菜单----------------------------------------------------------------------
function MENU(){
	clear
echo "========================================================="
echo "|   __  _____  ______  __  ____________  ____  __   ____|"
echo "|  /  |/  / / / / __ \/ / / /_  __/ __ \/ __ \/ /  / __/|"
echo "| / /|_/ / /_/ / /_/ / /_/ / / / / /_/ / /_/ / /___\ \  |"
echo "|/_/  /_/\____/\____/\____/ /_/  \____/\____/____/___/  |"
echo "|                                                       |"
echo "========================================================="
echo "                 欢迎使用木偶的工具箱                      "
echo "请输入你要使用的功能的序号:                                "
echo "1)获取本地IP"
echo "2)校对时间▶"
echo "3)系统信息"
read -p "请输入对应功能的序号：" choose
case $choose in
    1)
    getip
    sleep 1
    wait
    ;;
    2)
    sync_time
    sleep 1
    ;;
    3)
    fetch_ip_addresses_then
    wait
    ;;
    
esac
}
#----------------------------------------------------------------------------

#判断是否返回-----------------------------------------------------------------
function wait(){
    read -p "
1)返回工具箱
0)退出脚本
" wait1
    case $wait1 in
        1)
        MENU
        ;;
        0)
        exit 1
        ;;
        *)
        red "输入错误！请稍后重试"
        sleep 1
        wait
        ;;
    esac
}
#----------------------------------------------------------------------------


#获取本地IP------------------------------------------------------------------
function getip(){
red "===========================" 
curl ip.p3terx.com
red "==========================="
}
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#校对时间
function sync_time(){
	yum -y install ntpdate	&> /dev/null
	timedatectl set-timezone Asia/Shanghai
	ntpdate ntp1.aliyun.com
}
#----------------------------------------------------------------------------


# 函数: 获取IPv4和IPv6地址
fetch_ip_addresses() {
  ipv4_address=$(curl -s ipv4.ip.sb)
  # ipv6_address=$(curl -s ipv6.ip.sb)
  ipv6_address=$(curl -s --max-time 2 ipv6.ip.sb)
}


function fetch_ip_addresses_then(){
    # 获取IP地址
    fetch_ip_addresses

    if [ "$(uname -m)" == "x86_64" ]; then
      cpu_info=$(cat /proc/cpuinfo | grep 'model name' | uniq | sed -e 's/model name[[:space:]]*: //')
    else
      cpu_info=$(lscpu | grep 'Model name' | sed -e 's/Model name[[:space:]]*: //')
    fi

    cpu_usage=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
    cpu_usage_percent=$(printf "%.2f" "$cpu_usage")%

    cpu_cores=$(nproc)

    mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2f MB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

    disk_info=$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)", $3,$2,$5}')

    country=$(curl -s ipinfo.io/country)
    city=$(curl -s ipinfo.io/city)

    isp_info=$(curl -s ipinfo.io/org)

    cpu_arch=$(uname -m)

    hostname=$(hostname)

    kernel_version=$(uname -r)

    congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
    queue_algorithm=$(sysctl -n net.core.default_qdisc)

    # 尝试使用 lsb_release 获取系统信息
    os_info=$(lsb_release -ds 2>/dev/null)

    # 如果 lsb_release 命令失败，则尝试其他方法
    if [ -z "$os_info" ]; then
      # 检查常见的发行文件
      if [ -f "/etc/os-release" ]; then
        os_info=$(source /etc/os-release && echo "$PRETTY_NAME")
      elif [ -f "/etc/debian_version" ]; then
        os_info="Debian $(cat /etc/debian_version)"
      elif [ -f "/etc/redhat-release" ]; then
        os_info=$(cat /etc/redhat-release)
      else
        os_info="Unknown"
      fi
    fi

    clear
    output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
        NR > 2 { rx_total += $2; tx_total += $10 }
        END {
            rx_units = "Bytes";
            tx_units = "Bytes";
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "KB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "MB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "GB"; }

            if (tx_total > 1024) { tx_total /= 1024; tx_units = "KB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "MB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "GB"; }

            printf("总接收: %.2f %s\n总发送: %.2f %s\n", rx_total, rx_units, tx_total, tx_units);
        }' /proc/net/dev)


    current_time=$(date "+%Y-%m-%d %I:%M %p")


    swap_used=$(free -m | awk 'NR==3{print $3}')
    swap_total=$(free -m | awk 'NR==3{print $2}')

    if [ "$swap_total" -eq 0 ]; then
        swap_percentage=0
    else
        swap_percentage=$((swap_used * 100 / swap_total))
    fi

    swap_info="${swap_used}MB/${swap_total}MB (${swap_percentage}%)"

    runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')

    echo ""
    echo "系统信息查询"
    echo "------------------------"
    echo "主机名: $hostname"
    echo "运营商: $isp_info"
    echo "------------------------"
    echo "系统版本: $os_info"
    echo "Linux版本: $kernel_version"
    echo "------------------------"
    echo "CPU架构: $cpu_arch"
    echo "CPU型号: $cpu_info"
    echo "CPU核心数: $cpu_cores"
    echo "------------------------"
    echo "CPU占用: $cpu_usage_percent"
    echo "物理内存: $mem_info"
    echo "虚拟内存: $swap_info"
    echo "硬盘占用: $disk_info"
    echo "------------------------"
    echo "$output"
    echo "------------------------"
    echo "网络拥堵算法: $congestion_algorithm $queue_algorithm"
    echo "------------------------"
    echo "公网IPv4地址: $ipv4_address"
    echo "公网IPv6地址: $ipv6_address"
    echo "------------------------"
    echo "地理位置: $country $city"
    echo "系统时间: $current_time"
    echo "------------------------"
    echo "系统运行时长: $runtime"
    echo
}

#----------------------------------------------------------------------------
#开始
MENU
#----------------------------------------------------------------------------
