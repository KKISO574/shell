#!/bin/bash
#本脚本用于用户登入工具箱，注册
caidan(){
cat << EOF
===========菜单===========
||	  1.登入	||
||	  2.注册	||
||	  3.退出	||
==========================
EOF

read -p "请你输出你要的选项：" num
case $num in
 	1)dengru;;
    2)zhuce;;
    3)tuichu;;
esac
}

dengru(){
	read -p "请输入你的用户名：" name
	id $name &> /dev/null
	if [ $? -eq 0 ];then
		read -p "请输入你的密码 ：" pass
			if [[ ${#pass} -ge 8  && $pass =~ [a-z] && $pass =~ [A-Z] && $pass =~ [0-9] && $pass =~ [^0-Z] ]];then
    				while :
					do
						gongju
    				read -p "请你输入你需要的工具：" gg
    				case $gg in
    					1)
						echo "=====磁盘信息====="
							df -hT
						echo "=====磁盘信息====="
						read -p "继续y，退出n" yn
						if [ $yn = y ];then
								clear
						else
							exit 88
						fi
						;;
						2)
						echo "=====内存信息====="
							free -m
						echo "=====内存信息====="
               			read -p "继续y，退出n" yn
                		if [ $yn = y ];then
                        		clear
                		else
                        		exit 88
                		fi
						;;
						3)
						echo "=====CPU信息====="
							uptime
						echo "=====CPU信息====="
               			read -p "继续y，退出n" yn
                		if [ $yn = y ];then
                        		clear
                		else
                        		exit 88
                		fi
						;;
						4)
						echo "=====网络信息====="
						read -p "请输入你要用的网络接口号" hao
							netstat -anpt | grep $hao
						echo "=====网络信息====="
               			read -p "继续y，退出n" yn
                		if [ $yn = y ];then
                        		clear
                		else
                        		exit 88
                		fi
						;;
						5)
						echo "=====进程信息====="
						read -p "请输入你要查询的进程名" pss
							ps aux | grep $pss
						echo "=====进程信息====="
               			read -p "继续y，退出n" yn
                		if [ $yn = y ];then
                        		clear
                		else
                        		exit 88
                		fi
						;;
						6)
						echo "=======退出======="
							exit 88
						echo "=======退出======="
						;;
    				esac
					done
			else

    				echo "密码不符合规定"
    				echo "密码要求大于等于8位，小写字母，大写字母，特殊字符"
			fi
	else
		echo "用户有误"
	fi
}

gongju (){
cat << EOF
===========系统工具箱===========
||       1.查看磁盘信息        ||
||       2.查看内存信息        ||
||       3.查看CPU信息         ||
||       4.查看网络信息        ||
||       5.查看进程信息        ||
||       6.退出                ||
================================
EOF
}

zhuce(){
read -p "请输入你需要创建的用户名：" name
id $name &> /dev/null
if [ $? -eq 1 ];then
read -p "请设置$name的密码：" password
	if [[ ${#password} -ge 8  && $password =~ [a-z] && $password =~ [A-Z] && $password =~ [0-9] && $password =~ [^0-Z] ]];then
		echo "$password" | passwd --stdin $name &> /dev/null
		echo "$name用户密码设置成功，密码为$password"
	else
		echo "你设置的密码有误，请按规定设置"
		caidan		
	fi
else
	echo "$name用户创建有误"
	caidan
fi	
}

caidan
