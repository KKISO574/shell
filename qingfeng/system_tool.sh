#!/bin/bash
#本脚本用于系统工具
# 打印当前系统登录用户
print_logged_in_users() {
    who | awk '{print $1}' | sort | uniq
}

# 根据用户输入判断软件是否已安装并打印软件信息
check_and_print_software_info() {
    read -p "请输入要检查的软件名称： " software_name
    if command -v "$software_name" &> /dev/null; then
        echo "$software_name 已安装"
        # TODO: 打印软件信息命令
    else
        echo "$software_name 未安装"
    fi
}

# 输入时间段和日志路径统计 nginx 访问日志次数最多的 IP
analyze_nginx_log() {
    read -p "请输入日志路径： " log_path
    read -p "请输入开始时间（格式：15/Jul/2023:00:00:00）： " start_time
    read -p "请输入结束时间（格式：15/Jul/2023:00:00:00）： " end_time
    
    sed -n "/$start_time/,/$end_time/p" "$log_path" |awk '{print $1}' |sort|uniq -c |sort|tail -n 1|awk '{print $2}'
}

# 安装指定软件
install_software() {
    read -p "请选择要安装的软件：1.Nginx 2.MySQL 3.Apache 4.Vsftpd：" choice

    case $choice in
        1)
            # 安装 Nginx
            # TODO: 添加 Nginx 安装命令
            ;;
        2)
            # 安装 MySQL
            # TODO: 添加 MySQL 安装命令
            ;;
        3)
            # 安装 Apache
            # TODO: 添加 Apache 安装命令
            ;;
        4)
            # 安装 Vsftpd
            # TODO: 添加 Vsftpd 安装命令
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 获取系统 CPU 排名前 10 的进程
get_top_cpu_processes() {
    ps aux --sort=-%cpu | head -n 11
}

# 获取系统内存排名前 10 的进程
get_top_memory_processes() {
    ps aux --sort=-%mem | head -n 11
}

change_IP_address(){
    read -p "是否已经配置网卡服务[y/n]：" yn
    if [ $yn = n ];then
    echo "
    IPADDR=192.168.116.111
    NETMASK=255.255.255.0
    GATEWAY=192.168.116.2
    DNS1=192.168.116.2
    以上为默认格式，仅供参考！"        
        sed -ie 's/BOOTPROTO=dhcp/BOOTPROTO=static/;s/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-ens33
        read -p "请输入你设置的IP地址：" ip
        sed -i "$ a IPADDR=$ip"  /etc/sysconfig/network-scripts/ifcfg-ens33
            read -p "请输入掩码：" net
            sed -i "$ a NETMASK=$net" /etc/sysconfig/network-scripts/ifcfg-ens33
                read -p "请输入网关：" way
                sed -i "$ a GATEWAY=$way" /etc/sysconfig/network-scripts/ifcfg-ens33
                    read -p "请输入DNS：" dns
                    sed -i "$ a DNS1=$dns" /etc/sysconfig/network-scripts/ifcfg-ens33
                        echo "网卡配置成功！"
    else
        sed -i '16,19 s/\(.*\)/#\1/'  /etc/sysconfig/network-scripts/ifcfg-ens33
        echo "注意，16-19段已被注释！！！"
        read -p "是否需要配置网卡服务【y/n】：" YN
        if [ $YN = y ];then
            echo "
            IPADDR=192.168.116.111
            NETMASK=255.255.255.0
            GATEWAY=192.168.116.2
            DNS1=192.168.116.2
            以上为默认格式，仅供参考！"        
        sed -ie 's/BOOTPROTO=dhcp/BOOTPROTO=static/;s/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-ens33
        read -p "请输入你设置的IP地址：" ipp
        sed -i "$ a IPADDR=$ipp"  /etc/sysconfig/network-scripts/ifcfg-ens33
            read -p "请输入掩码：" nett
            sed -i "$ a NETMASK=$nett" /etc/sysconfig/network-scripts/ifcfg-ens33
                read -p "请输入网关：" wayy
                sed -i "$ a GATEWAY=$wayy" /etc/sysconfig/network-scripts/ifcfg-ens33
                    read -p "请输入DNS：" dnss
                    sed -i "$ a DNS1=$dnss"  /etc/sysconfig/network-scripts/ifcfg-ens33  
                        echo "网卡配置成功！"
        fi
    fi
}

disable_firewall(){
    systemctl stop firewalld;systemctl disable firewalld;
        echo "防火墙已关闭,关闭开机自启服务！"
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        echo "selinux已关闭，已关闭开机自启服务！"
}

on_DNS(){
    sed -i '115s/#UseDNS yes/UseDNS no/'    /etc/ssh/sshd_config;systemctl restart sshd
    echo "DNS已关闭！！！"
}

backup_copy(){
    #每周日进行全量备份，周一到周六进行增量备份
    #关闭防火墙
    systemctl stop firewalld
    setenforce 0
    #备份路径
    back_dir="/backup"
    log_dir="/backup_log"
    full_backup_dir="backup/full"
    inc_backup_dir="backup/inc"
    #变量时间
    log_date=$(date "+%F-%T")
    #定义用户，密码
    MY_USER="root"
    MY_PASS="1"
    #验证日志目录路径是否存在
    [ -d $back_dir ] || mkdir $back_dir
    [ -d $log_dir ] || mkdir $log_dir
    [ -d $full_backup_dir ] || mkdir $full_backup_dir
    [ -d $inc_backup_dir ] || mkdir $inc_backup_dir
    #全量备份函数
    full_back(){
    #全量备份命令
    innobackupex --user=$MY_USER --password=$MY_PASS $full_backup_dir
    if [$? -eq 0];then
        echo "${log_date} full OK!!!" >> $log_dir/OK_log
    else    
        echo "${log_date} NO found full!!!" >> $log_dir/err_log
    fi
    }   
    #获取上周日时间
    sunday=$(date -d "last sunday" +%F)
    #获取前一天的时间
    yesterday=$(date -d "yesterday" +%F)
    #增量备份函数
    inc_back(){
    #判断当前时间是否是周一
    if [ $week_date -eq 1 ];then
        #查找文件
        local full_backup_dir=$(find $backup_dir -name ${sunday}*)
        innobackupex --user=$MY_USER --password=$MY_PASS --incremental ${inc_backup_dir} --incremental-basedir=${full_backup_dir}
        #判断是否执行成功，写入定义日志文件
        if [$? -eq 0];then
            echo "${log_date} full OK!!!" >> $log_dir/OK_log
        else
            echo "${log_date} NO found full!!!" >> $log_dir/err_log
        fi
    else
        #查找前一天的文件路径
        local yesterday_backup_dir=$(find $backup_dir -name ${yesterday}*)
        innobackupex --user=$MY_USER --password=$MY_PASS --incremental ${inc_backup_dir} --incremental-basedir=${yesterday_backup_dir}
        # 判断命令是否执行成功,写入日志文件
        if [$? -eq 0];then
            echo "${log_date} full OK!!!" >> $log_dir/OK_log
        else
            echo "${log_date} NO found full!!!" >> $log_dir/err_log
        fi
    fi
    }

    #查看当前时间是周几
    week_date=$(date +%u)
    #判断当前时间是不是周日，如果是进去全量备份，如果不是就进行增量备份
    if [ $week_date -eq 7 ];then
        full_backup
    else
        inc_backup
    fi
}

check_the_time(){
    # 关闭防火墙
    systemctl stop firewalld
    setenforce 0
    # 下载软件
    yum -y instal ntpdate
    # 查看当前时区
    timedatectl
    # 列出可用时区
    #timedatectl list-timezones
    # 修改上海时区
    timedatectl set-timezone Asia/Shanghai
    # 验证修改是否生效
    timedatectl
    # 对时
    ntpdate ntp.aliyun.com
    echo "对时成功，当前时间为：" 
    date +'%F %H:%M:%S'
}

COPY_INSTALL(){
master=ip1
slave=ip2
read -p "请输入master的IP地址：" IP1
read -p "请输入slave的IP地址：" IP2
# 关闭防火墙
systemctl stop firewalld;setenforce 0
# 域名解析
cat >> /etc/hosts << EOF
$IP1 master
$IP2 slave
EOF
# ping下网络
ping slave &> /dev/null
if [ $? -eq 0 ];then
    echo "网络正常，可以使用"
else
    echo "sorry 网络不通"
fi
# 添加主机配置
cat >> /etc/my.cnf << EOF
log-bin=/var/lib/mysql/master
server-id=1
gtid_mode=ON
enforce_gtid_consistency=1
EOF
# 主机授权
grant replication slave,super,reload on *.* to slave@'%' identified by 'Qianfeng123!';
# 刷新权限
flush privileges;
# 此项为互为主从配置
change master to master_host='slave',master_user='slave',master_password='1',master_auto_position=1;
# 启动slave服务
start slave;
# 查看服务状态，是否有error
show slave status\G
}

exit_menu(){
    echo "再见！！！"
    break
}

# 主菜单选择
main_menu() {
    while true; do
        echo "========== 主菜单 =========="
        echo "1) 打印当前系统登录用户"
        echo "2) 检查软件是否已安装并打印软件信息"
        echo "3) 输入时间段和日志路径统计nginx访问日志次数最多的IP"
        echo "4) 安装指定软件"
        echo "5) 获取系统CPU排名前10的进程"
        echo "6) 获取系统内存排名前10的进程"
        echo "7) 更改IP"
        echo "8) 关闭防火墙"
        echo "9) 开启DNS"
        echo "10) 备份"
        echo "11) 对时"
        echo "12) 主从复制"
        echo "13) 返回上级菜单"
        echo "14) 退出"
        echo "============================"

        read -p "请输入选项： " select
        case $select in
            1)
                print_logged_in_users
                ;;
            2)
                check_and_print_software_info
                ;;
            3)
                analyze_nginx_log
                ;;
            4)
                install_software
                ;;
            5)
                get_top_cpu_processes
                ;;
            6)
                get_top_memory_processes
                ;;
            7)
                change_IP_address
                ;;
            8)
                disable_firewall
                ;;
            9)
                on_DNS
                ;;
            10)
                backup_copy
                ;;
            
            11)
                check_the_time
                ;;
            12)
                COPY_INSTALL
                ;;
            13)
                echo "请重新选择你需要的菜单"
                continue 2
                ;;
            14)
                exit_menu
                ;;
            *)
                echo "无效的选择，请重新输入"
                ;;
        esac

        echo "============================"
        read -p "按任意键返回主菜单" any_key
        clear
    done
}

# 运行主菜单
main_menu



