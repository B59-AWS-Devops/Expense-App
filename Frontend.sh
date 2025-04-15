#!/bin/bash

# --- FRONTEND SETUP SCRIPT ---

# Update system and install Nginx
echo -e "Installing Nginx..."
dnf install nginx -y &>> /tmp/frontend.log
if [ $? -eq 0 ]; then
    echo "Nginx installed successfully."
else
    echo "Failed to install Nginx. Check /tmp/frontend.log for details."
    exit 1
fi

# Enable and start nginx
echo -e "Starting Nginx.."
systemctl enable nginx
systemctl start nginx
if [ $? -eq 0 ]; then
    echo -e "Nginx Started \e[32m successfully\e[0m"
else
    echo "Failed to start Nginx. Check /tmp/frontend.log for details."
    exit 1
fi

# Check if nginx is running
systemctl status nginx
curl -I http://localhost

# Clear existing default web page content
rm -rf /usr/share/nginx/html/*

# Download frontend zip
echo "Downloading frontend..."
curl -o /tmp/frontend.zip https://expense-web-app.s3.amazonaws.com/frontend.zip

# Unzip frontend to nginx html directory
cd /usr/share/nginx/html
#check unzip is installed

unzip /tmp/frontend.zip &>> /tmp/frontend.log

# Create Nginx reverse proxy configuration
cat <<EOF > /etc/nginx/default.d/expense.conf
proxy_http_version 1.1;

location /api/ {
    proxy_pass http://localhost:8080/;
}

location /health {
    stub_status on;
    access_log off;
}
EOF

# Restart nginx to apply changes
echo "Restarting nginx..."
systemctl restart nginx

# Confirm nginx status
systemctl status nginx

# Optional: Set hostname
hostnamectl set-hostname Frontend

echo "Frontend setup completed successfully."