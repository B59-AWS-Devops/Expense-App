#!/bin/bash

# --- FRONTEND SETUP SCRIPT ---

# Update system and install Nginx

component=frontend
log_file=/tmp/$component.log
Package=nginx

VALIDATE () {
    if [ $(id -u) -eq 0 ]; then
        echo -e "\e[32mUser is root\e[0m"
    else
        echo -e User is not root. Please run as root."\e[31m sudo sh $0\e[0m"
        exit 2
    fi
}

stat () {
if [ $1 -eq 0 ]; then
    echo -e "\e[32msuccessfully\e[0m"
else
    echo -e "\e[31mfailure. Check $log_file  for details.\e[0m"
    exit 1
fi
}




echo -n "Installing Nginx : "
dnf install nginx -y &>> $log_file 

stat $?

# Enable and start nginx
echo -n "Starting Nginx : "
systemctl enable $Package &>> $log_file 
systemctl start $Package &>> $log_file 

stat $?



# Check if nginx is running
echo -n "Checking Nginx status : "
systemctl status $Package &>> $log_file 
curl -I http://localhost

# Clear existing default web page content
echo -n "Clearing default web page content : "
rm -rf /usr/share$Package/html/* &>> $log_file 
stat $?

# Download frontend zip
echo -n "Downloading frontend..."
curl -o /tmp/frontend.zip https://expense-web-app.s3.amazonaws.com/frontend.zip  &>> $log_file 
stat $?


# Unzip frontend to nginx html directory
echo -n "Unzipping frontend to nginx html directory..."
cd /usr/share/$Package/html &>> $log_file 
stat $?

#check unzip is installed

unzip -o /tmp/frontend.zip &>> $log_file 
stat $?

##configuring proxy
echo -n "configuring proxy :"
cp /home/ec2-user/Expense-App/proxy.conf /etc/nginx/default.d/expense.conf &>> $log_file
stat $?

# Restart nginx to apply changes
echo -n "Restarting nginx :"
systemctl restart $Package &>> $log_file 
stat $?

# Confirm nginx status
echo -n "Confirming Nginx status :"
systemctl status $Package &>> $log_file 
stat $?


# Optional: Set hostname
hostnamectl set-hostname Frontend


echo "Frontend setup completed successfully."