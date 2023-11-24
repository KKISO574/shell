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
    echo "不支持你当前系统，请使用Ubuntu,Debian,Centos系统"
    exit 1
fi


tool() {
    clear
    echo " ________      ___  ___          ________          ___  __             ___    ___      ________          ___  ___"
    echo '|\  _____\    |\  \|\  \        |\   ____\        |\  \|\  \          |\  \  /  /|    |\   __  \        |\  \|\  \'
    echo '\ \  \__/     \ \  \\\  \       \ \  \___|        \ \  \/  /|_        \ \  \/  / /    \ \  \|\  \       \ \  \\\  \'
    echo ' \ \   __\     \ \  \\\  \       \ \  \            \ \   ___  \        \ \    / /      \ \  \\\  \       \ \  \\\  \'
    echo '  \ \  \_|      \ \  \\\  \       \ \  \____        \ \  \\ \  \        \/  /  /        \ \  \\\  \       \ \  \\\  \'
    echo '   \ \__\        \ \_______\       \ \_______\       \ \__\\ \__\     __/  / /           \ \_______\       \ \_______\'
    echo '    \|__|         \|_______|        \|_______|        \|__| \|__|    |\___/ /             \|_______|        \|_______| '
    echo '                                                                    \|___|/'
    echo "============================="
    echo "1.登录"
   
    echo "2.注册"
   
    echo "0.退出"
    echo "============================="
    read -p "请输入你要使用的功能:" num
   
    menu
}
tool2() {
        clear
        echo "============================="
        echo "1.系统信息查询"
        echo "2.常用软件包安装"
        echo "3.数据库操作"
        echo "0.返回上一层"

        read -p "输入你要使用的功能：" num2
    menu2
}

menu() {
    case $num in 
        1)
            n1
            ;;
        2)
            n2
            ;;
        0)
            n0
            ;;
        *)
            n8
            clear
            tool
            ;;
    esac
}

menu2() {
    case $num2 in
        1)
        sys1
        ;;
        2)
        sys2
        ;;
        3)
        sys3
        ;;
        0)
        tool
        clear
        ;;
        *)
         read -p "输入错误，按任意键返回上级菜单：" back
         tool2
            ;;
    esac
}

sys1() {
    # 函数: 获取IPv4和IPv6地址
    fetch_ip_addresses() {
      ipv4_address=$(curl -s ipv4.ip.sb)
      # ipv6_address=$(curl -s ipv6.ip.sb)
      ipv6_address=$(curl -s --max-time 2 ipv6.ip.sb)

    }

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
sys2(){
  while true; do
      echo " ▼ "
      echo "安装常用工具"
      echo "------------------------"
      echo "1. curl 下载工具"
      echo "2. wget 下载工具"
      echo "3. sudo 超级管理权限工具"
      echo "4. socat 通信连接工具 （申请域名证书必备）"
      echo "5. htop 系统监控工具"
      echo "6. iftop 网络流量监控工具"
      echo "7. unzip ZIP压缩解压工具z"
      echo "8. tar GZ压缩解压工具"
      echo "9. tmux 多路后台运行工具"
      echo "10. ffmpeg 视频编码直播推流工具"
      echo "------------------------"
      echo "31. 全部安装"
      echo "32. 全部卸载"
      echo "------------------------"
      echo "0. 返回主菜单"
      echo "------------------------"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y curl
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install curl
              else
                  echo "未知的包管理器!"
              fi

              ;;
          2)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y wget
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install wget
              else
                  echo "未知的包管理器!"
              fi
              ;;
            3)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install sudo
              else
                  echo "未知的包管理器!"
              fi
              ;;
            4)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y socat
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install socat
              else
                  echo "未知的包管理器!"
              fi
              ;;
            5)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y htop
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install htop
              else
                  echo "未知的包管理器!"
              fi
              ;;
            6)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y iftop
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install iftop
              else
                  echo "未知的包管理器!"
              fi
              ;;
            7)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y unzip
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install unzip
              else
                  echo "未知的包管理器!"
              fi
              ;;
            8)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y tar
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install tar
              else
                  echo "未知的包管理器!"
              fi
              ;;
            9)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y tmux
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install tmux
              else
                  echo "未知的包管理器!"
              fi
              ;;
            10)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y ffmpeg
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install ffmpeg
              else
                  echo "未知的包管理器!"
              fi
              ;;


          31)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y curl wget sudo socat htop iftop unzip tar tmux ffmpeg
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install curl wget sudo socat htop iftop unzip tar tmux ffmpeg
              else
                  echo "未知的包管理器!"
              fi
              ;;

          32)
              clear
              if command -v apt &>/dev/null; then
                  apt remove -y htop iftop unzip tmux ffmpeg
              elif command -v yum &>/dev/null; then
                  yum -y remove htop iftop unzip tmux ffmpeg
              else
                  echo "未知的包管理器!"
              fi
              ;;

          0)
        tool2
        clear
        ;;

          *)
              echo "无效的输入!"
              ;;
      esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
  done

}

sys3() {
    read -p "请输入你的数据库管理员账号：" mysql_user
    read -p "请输入 $mysql_user 的密码：" mysql_password
    read -p "请输入你的数据库主机地址：" host_mysql
    echo "请稍等~"
    # 数据库的信息
    # ---------------------#
    MYSQL_USER=$mysql_user
    MYSQL_PASSWORD=$mysql_password
    MYSQL_HOST=$host_mysql
    # ---------------------#

    read -p "是否需要创建新的库表：" true1
    if [[ $true1 == y ]]; then
        read -p "请输入用于创建的数据库名：" mysql_db
        read -p "请输入用于创建的数据库表名：" mysql_t1

        # 读取用户输入的表结构
        read -p "请输入用于功能的数据库表结构（例如：'username VARCHAR(20) UNIQUE,password VARCHAR(30)'）：" table_structure

        MYSQL_DB=$mysql_db
        MYSQL_TABLE=$mysql_t1

        mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST -e "CREATE DATABASE $MYSQL_DB;"
        mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DB -e "CREATE TABLE \`$MYSQL_TABLE\` ($table_structure);"

        # 读取用户输入的数据
        read -p "请输入要插入的数据（例如：'zhangsan','123456'）：" insert_values
        mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DB -e "INSERT INTO \`$MYSQL_TABLE\` VALUES($insert_values);"

        echo "已插入数据：$insert_values"
    else
        read -p "请输入已存在的数据库名：" mysql_db
        read -p "请输入已存的数据库表在名：" mysql_t1
        MYSQL_DB=$mysql_db
        MYSQL_TABLE=$mysql_t1

        mysqldb=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST -e "SHOW CREATE DATABASE $MYSQL_DB ;")

        if [ -n "$mysqldb" ]; then
            echo "已查询到数据库！"
            wait

            mysqltable=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST $MYSQL_DB -e "SHOW CREATE TABLE \`$MYSQL_TABLE\` ;")
            if [ -n "$mysqltable" ]; then
                echo "已查询到数据库中的表！"
                wait
            else
                echo "输入的数据库表不存在！"
                wait
                select_db_t1
            fi
        else
            echo "输入的数据库不存在！"
            wait
            select_db_t1
        fi
    fi
}




n1() {
    echo "远程校验服务器"
    read -p "请输入你的数据库远程地址" mysql_host
    read -p "请输入你的数据库远程用户" mysql_root
    read -p "请输入你的数据库密码" mysql_passwd
    read -p "请输入你的用户名:" user
    result=$(mysql -u$mysql_root -p$mysql_passwd -h$mysql_host -e "SELECT name FROM ces.user WHERE name='$user'" 2>/dev/null)
    if [ -n "$result" ]; then
        read -p "请输入密码:" passwd
    else
        n8
    fi

    result=$(mysql -u$mysql_root -p$mysql_passwd -h$mysql_host -e "SELECT passwd FROM ces.user WHERE name='$user' AND passwd='$passwd'" 2>/dev/null)
    if [ -n "$result" ]; then
        clear
        echo "登录成功"
        tool2
    else 
        echo "密码错误"
        n8
    fi
}

n2() {
    read -p "请输入需要注册的用户名：" reid
    result=$(mysql -u$mysql_root -p$mysql_passwd -h$mysql_host -e "SELECT name FROM ces.user WHERE name='$reid'" 2>/dev/null)
    if [ -z "$result" ]; then
        read -p "请输入注册的密码：" redi_passwd
        if echo "$redi_passwd" | grep -E '[a-z]' | grep -E '[A-Z]' | grep -E '[0-9]' | grep -E '[@#$%^&*!]' >/dev/null && [ ${#redi_passwd} -ge 8 -a ${#redi_passwd} -le 16 ] ; then
            echo "密码符合。"
            mysql -u$mysql_root -p$mysql_passwd -h$mysql_host -e "INSERT INTO ces.user SET name='$reid', passwd='$redi_passwd'" >/dev/null 
        else
            echo "密码复杂度不符合"
            n8
        fi

        if [ $? -eq 0 ]; then
            echo "注册成功，请登录"
            tool
        else
            echo "注册信息有问题，或者已经被注册了"
            n8
        fi
    else
        echo "用户名已存在，请重新输入"
        n8
    fi
}

n0() {
    exit
}

n8() {
    read -p "输入错误，请任意键返回。" back
    clear
    tool
}



# 主循环
clear
tool
