#!/bin/bash

## Setup backend script

component=backend
log_file=/tmp/$component.log
Package=nodejs
AppUser=expense

## Prompt for MySQL credentials
read -p "Enter the MySQL username: " mysql_user
read -s -p "Enter the MySQL password: " mysql_password
echo

## Validate root user
if [ $(id -u) -ne 0 ]; then
    echo -e "\e[31mUser is not root. Please run as root: sudo sh $0\e[0m"
    exit 2
else
    echo -e "\e[32mUser is root\e[0m"
fi

## Common status check function
stat () {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32msuccessfully\e[0m"
  else
    echo -e "\e[31mfailure. Check $log_file for details.\e[0m"
    exit 1
  fi
}

## Disable and enable Node.js
echo -n "Disabling Node.js module: "
dnf module disable $Package -y &>> $log_file
stat $?

echo -n "Enabling Node.js 20 module: "
dnf module enable $Package:20 -y &>> $log_file
stat $?

## Install Node.js
echo -n "Installing $Package: "
dnf install $Package -y &>> $log_file
stat $?

## Create app user if not exists
id $AppUser &>> $log_file
if [ $? -eq 0 ]; then
  echo -e "\e[33mUser already exists. Skipping user creation.\e[0m"
else
  echo -n "Creating user: "
  useradd $AppUser &>> $log_file
  stat $?
fi

## Create /app directory
echo -n "Creating /app directory: "
mkdir -p /app &>> $log_file
stat $?

## Download backend code
echo -n "Downloading application code: "
curl -o /tmp/$component.zip https://expense-web-app.s3.amazonaws.com/$component.zip &>> $log_file
stat $?

## Unzip code
echo -n "Unzipping application archive: "
cd /app &>> $log_file
unzip -o /tmp/$component.zip &>> $log_file
stat $?

## Install dependencies
echo -n "Installing Node.js dependencies: "
npm install &>> $log_file
stat $?

## Configure systemd service
echo -n "Configuring systemd service: "
cp /home/ec2-user/Expense-App/backend.service /etc/systemd/system/$component.service &>> $log_file
stat $?

## Set ownership and permissions
echo -n "Setting permissions: "
chown -R $AppUser:$AppUser /app
chmod -R 775 /app
stat $?

## Install MySQL client
echo -n "Installing MySQL client: "
dnf install mysql -y &>> $log_file
stat $?

## Load schema
echo -n "Loading schema to MySQL: "
mysql -h 172.31.91.207 -u$mysql_user -p$mysql_password < /app/schema/backend.sql &>> $log_file
stat $?

## Reload systemd and start service
echo -n "Reloading systemd: "
systemctl daemon-reload &>> $log_file
stat $?

echo -n "Starting backend service: "
systemctl start $component &>> $log_file
systemctl enable $component &>> $log_file
stat $?

echo -e "\e[32m$component setup completed successfully\e[0m"

