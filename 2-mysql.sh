#!/bin/bash

### Mysql setup script

component=Database

Package_Name=mysql
Package_service=mysqld

source /home/ec2-user/Expense-App/common.sh
read -p "Enter the MYSQL username :" mysql_user
read -s -p "Enter the MYSQL password:" mysql_password
echo


##Installing mysql
echo -n "Installing mysql : "
 dnf install $Package_Name-server -y &>> $log_file
 stat $?

 ##Enable and start mysql
 echo -n "starting mysql :"
 echo -n "enable mysql :"
systemctl start $Package_service &>> $log_file
systemctl enable $Package_service &>> $log_file
stat $?

##setting username and password for mysql
echo -n "setting my sql username and password :"
mysql_secure_installation --set-$mysql_user-pass $mysql_password &>> $log_file
stat $?


echo -e "\e[32m"database created"\e[0m"