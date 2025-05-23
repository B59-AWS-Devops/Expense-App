#!/bin/bash

## Setup backend script

component=backend

Package=nodejs
AppUser=expense

source /home/ec2-user/Expense-App/common.sh
## Prompt for MySQL credentials
read -p "Enter the MySQL username: " mysql_user
read -s -p "Enter the MySQL password: " mysql_password
echo


## Disable and enable Node.js module
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

## Unzip backend code
echo -n "Unzipping application archive: "
cd /app &>> $log_file
unzip -o /tmp/$component.zip &>> $log_file
stat $?

## Install Node.js dependencies
echo -n "Installing Node.js dependencies: "
npm install &>> $log_file
stat $?

## Configure systemd service
echo -n "Configuring systemd service: "
cp /home/ec2-user/Expense-App/Backendconfig.service /etc/systemd/system/${component}.service &>> $log_file
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

## Load database schema
echo -n "Loading schema to MySQL: "
mysql -h database.clouddevops.life -u$mysql_user -p$mysql_password < /app/schema/backend.sql &>> $log_file
stat $?

## Reload systemd and start backend service
echo -n "Reloading systemd: "
systemctl daemon-reload &>> $log_file
stat $?

echo -n "Starting backend service: "
systemctl start $component &>> $log_file
systemctl enable $component &>> $log_file
stat $?

echo -e "\e[32m$component setup completed successfully\e[0m"
