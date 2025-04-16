#!/bin/bash

# --- FRONTEND SETUP SCRIPT ---

# Update system and install Nginx

component=frontend
log_file=/tmp/$component.log

echo -n "Installing Nginx : "
dnf install nginx -y &>> $log_file 
if [ $? -eq 0 ]; then
    echo -e "\e[32mNginx installed successfully\e[0m"
else
    echo -e "\e[31mFailed to install Nginx. Check $log_file for details.\e[0m"
    exit 1
fi

# Enable and start nginx
echo -n "Starting Nginx : "
systemctl enable nginx &>> $log_file 
systemctl start nginx &>> $log_file 
if [ $? -eq 0 ]; then
    echo -e "\e[32mNginx started successfully\e[0m"
else
    echo -e "\e[31mFailed to start Nginx. Check $log_file  for details.\e[0m"
    exit 1
fi


# Check if nginx is running
echo -n "Checking Nginx status : "
systemctl status nginx &>> $log_file 
curl -I http://localhost

# Clear existing default web page content
echo -n "Clearing default web page content : "
rm -rf /usr/share/nginx/html/* &>> $log_file 
if [ $? -eq 0 ]; then
    echo -e "\e[32mCleared default web page content successfully\e[0m"
    exit 0
else
    echo -e "\e[31mFailed to clear default web page content. Check /tmp/frontend.log for details.\e[0m"
    exit 1
fi

# Download frontend zip
echo -n "Downloading frontend..."
curl -o /tmp/frontend.zip https://expense-web-app.s3.amazonaws.com/frontend.zip  &>> $log_file 
if [ $? -eq 0 ]; then
    echo -e "\e[32mFrontend zip downloaded successfully\e[0m"
else
    echo -e "\e[31mFailed to download frontend zip. Check $log_file  for details.\e[0m"
    exit 1
fi

# Unzip frontend to nginx html directory
echo -n "Unzipping frontend to nginx html directory..."
cd /usr/share/nginx/html &>> $log_file 
if [ $? -eq 0 ]; then
    echo -e "\e[32mChanged directory to /usr/share/nginx/html successfully\e[0m"
else
    echo -e "\e[31mFailed to change directory. Check $log_file  for details.\e[0m"
    exit 1
fi
#check unzip is installed

unzip -o /tmp/frontend.zip &>> $log_file 
if [ $? -eq 0 ]; then
    echo -e "\e[32mFrontend unzipped successfully\e[0m"
else
    echo -e "\e[31mFailed to unzip frontend. Check $log_file  for details.\e[0m"
    exit 1
fi


# Restart nginx to apply changes
echo -n "Restarting nginx..."
systemctl restart nginx &>> $log_file 
if  [ $? -eq 0 ]; then
    echo -e "\e[32mNginx restarted successfully\e[0m"
else
    echo -e "\e[31mFailed to restart Nginx. Check $log_file  for details.\e[0m"
    exit 1
fi

# Confirm nginx status
echo -n "Confirming Nginx status..."
systemctl status nginx &>> $log_file 
if  [ $? -eq 0 ]; then
    echo -e "\e[32mNginx is running\e[0m"
else
    echo -e "\e[31mNginx is not running. Check $log_file  for details.\e[0m"
    exit 1
fi

# Optional: Set hostname
hostnamectl set-hostname Frontend


echo "Frontend setup completed successfully."