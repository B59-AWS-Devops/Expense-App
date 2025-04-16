#!/bin/bash
 
 ## setup backend script

 component=Backend
log_file=/tmp/$component.log
Package=nodejs
AppUser=expense

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


##diabale and enable Nodejs
echo -n "Disable and enable $Package :"
dnf module list 
dnf module disable $Package -y
dnf module enable $Package:20 -y 
stat $?

##Installing nodejs
echo -n "Installing $Package:"
dnf install $Package -y &>> $log_file
stat $?


##Creating the user and the directory
id $AppUser &>> $log_file
if [$? -eq 0 ]; then
    echo -e "\e[31mUser already exists\e[0m"
    echo -n "skipping the user creation"
    else
    echo -n "creating the user:"
    useradd $AppUser &>> $log_file
    mkdir  /app &>> $log_file
    fi
    stat $?
##Downloading the application code
echo -n "Downloading the application code:"
curl -o /tmp/backend.zip https://expense-web-app.s3.amazonaws.com/backend.zip
##changing the directory and unzip the file
echo -n"unzipping the file:"
cd /app
unzip /tmp/backend.zip &>> $log_file
stat $?

##Creating the artifacts
echo -n "Creating the artifacts:"
npm install &>> $log_file   

##Configuring the service
echo -n "configuring the service:"
cp /home/ec2-user/Expense-App/$Backend.service /etc/systemd/system/$component.service &>> $log_file
stat $?

##Setting the permissions
echo -n "Setting the permissions:"
chmod -R 775 /app
chown -R $AppUser:$AppUser /app
stat $?

##To load the schema 
##Install mysql client on the backend server
echo -n "Installing mysql client:"
dnf install mysql-server -y &>> $log_file
stat $?

##Load the schema
echo -n "Loading the schema:"
mysql -h  172.31.91.207 -uroot -pExpenseApp@1 < /app/schema/backend.sql 

##reload demon
echo -n "Reloading the daemon:"
systemctl daemon-reload &>> $log_file
stat $?

## start and enable the service
echo -n "Starting the service:"
systemctl start $component &>> $log_file
systemctl enable $component &>> $log_file
stat $?

echo -e "\e[32m$component setup completed successfully\e[0m"
