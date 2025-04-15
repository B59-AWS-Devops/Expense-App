#/!bin/bash

#Installing nginx
dnf install nginx -y  
systemctl enable nginx    
systemctl start nginx 
#Testing whetheter nginx is running or not
systemctl status nginx
curl -I http://localhost
#Deleting the content of the default nginx page
rm -rf /usr/share/nginx/html/* 
#creating a new index.html file
curl -o /tmp/frontend.zip https://expense-web-app.s3.amazonaws.com/frontend.zip
#changing the directory to /usr/share/nginx/html
 cd /usr/share/nginx/html 
 #unzipping the frontend.zip file
 unzip /tmp/frontend.zip
 #creating the nginx reverse proxy configuration file
 vim /etc/nginx/default.d/expense.conf << Configuration.sh
 #restart nginx
 systemctl restart nginx
 #status of nginx
 systemctl status nginx

 #completed successfully
