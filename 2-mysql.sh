#!/bin/bash

### Mysql setup script

Component=Database
log_file=/tmp/$component.log
Package_Name=mysql
Package_service=mysqld

##common functions
    if [ $(id -u) -eq 0 ]; then
        echo -e "\e[32mUser is root\e[0m"
    else
        echo -e User is not root. Please run as root."\e[31m sudo sh $0\e[0m"
        exit 2
    fi


stat () {
if [ $1 -eq 0 ]; then
    echo -e "\e[32msuccessfully\e[0m"
else
    echo -e "\e[31mfailure. Check $log_file  for details.\e[0m"
    exit 1
fi
}

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
mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $log_file
stat $?


echo -e "\e[32m"database created"\e[0m"