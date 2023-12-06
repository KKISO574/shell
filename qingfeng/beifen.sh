#!/bin/bash
#本脚本用于mysql备份
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
