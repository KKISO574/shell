#!/bin/sh
#系统判断
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

#安装jdk环境以及 mysql数据库

tool(){
echo "========================"
echo "请输入你要使用的功能的序号:                     "
echo "1.校对时间"
echo "2.安装常用软件包"
echo "3.安装jdk以及mysql和下载tomcat"
read -p "请输入对应功能的序号：" choose
}
case $choose in 
    1)
    time
    ;;
    2)
    soft
    ;;
    3)
    install
    ;;
    *)
    echo "输入错误返回"
    tool
    ;;
esac



install(){
yum install -y java-1.8.0-openjdk.x86_64 mariadb-server

}

soft(){
yum install wegt curl vim net-tools 





}




function time(){
	yum -y install ntpdate	&> /dev/null
	timedatectl set-timezone Asia/Shanghai
	ntpdate ntp1.aliyun.com
    date
}

#循环
tool