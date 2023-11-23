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
read -p "请输入对应功能的序号：" choose
case $choose in
    1)
    getip
    sleep 1
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



#----------------------------------------------------------------------------
#开始
MENU
#----------------------------------------------------------------------------
