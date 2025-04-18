#!/bin/bash

##This is a common script for all the components


log_file=/tmp/$component.log

##common functions
    if [ $(id -u) -eq 0 ]; then
        echo -e "\e[32mUser is root\e[0m"
    else
        echo -e User is not root. Please run as root."\e[31m sudo sh $0\e[0m"
        exit 2
    fi


stat () {
if [ $1 -eq 0 ]; then
    echo -e "\e[32msuccess\e[0m"
else
    echo -e "\e[31mfailure. Check $log_file  for details.\e[0m"
    exit 1
fi
}