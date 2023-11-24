#!/bin/bash
# 本脚本用于MySQL编译安装初始密码的更改
# 停止服务
systemctl stop mysqld
# 杀死进程
pkill mysqld
# 删除初始化文件
rm -rf /usr/local/mysql/data
# 重新初始化
mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data &> chu_password.txt
#启动服务
systemctl start mysqld
# 获取密码
Mysql_Pass=Qianfeng@123
temp_password=$(sudo cat chu_password.txt | grep 'temporary password' | awk '{print $NF}')
mysql -uroot -p"${temp_password}" --connect-expired-password <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY "${Mysql_Pass}";
FLUSH PRIVILEGES;
EOF
# 登录测试
#show databases;
#if [ $? =0 ];then
#	echo "查看数据库正常！！！"
#else
#	echo "无法查看数据库！！！"
#fi