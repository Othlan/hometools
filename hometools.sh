#!/bin/bash

set -e

echo "--- 1. Creating Directory Structure ---"
sudo mkdir -p /opt/hometools/data/metube

sudo chown -R $USER:docker /opt/hometools/data
sudo chmod -R 775 /opt/hometools/data

echo "--- 2. Configuring Firewall (UFW) ---"
if ! command -v ufw > /dev/null 2>&1; then
    echo "Installing UFW..."
    sudo apt update
    sudo apt install -y ufw
fi
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp

read -rp "Are you using Nginx Proxy? (y/n): " USE_NGINX
if [[ "$USE_NGINX" =~ ^[Yy]$ ]]; then
    read -rp "Enter Nginx Proxy IP (e.g., 192.168.1.100): " NGINX_IP
    if [[ -z "$NGINX_IP" ]]; then
        echo "Error: Nginx IP is required for restricted access. Exiting."
        exit 1
    fi
    sudo ufw allow from "$NGINX_IP" to any port 8080 comment 'MeTube via Proxy'
    sudo ufw allow from "$NGINX_IP" to any port 8081 comment 'Stirling PDF via Proxy'
else
    echo "Warning: Allowing public access to ports 8080 and 8081."
    sudo ufw allow 8080/tcp comment 'MeTube Open'
    sudo ufw allow 8081/tcp comment 'Stirling PDF Open'
fi

echo "y" | sudo ufw enable

echo "--- 3. Launching Services ---"
if ! command -v docker > /dev/null 2>&1; then
    echo "Error: Docker is not installed. Run prep_server.sh first."
    exit 1
fi
if ! docker compose version > /dev/null 2>&1; then
    echo "Error: Docker Compose is not available. Run prep_server.sh first."
    exit 1
fi
docker compose up -d

echo "--------------------------------------------------------"
echo " HOMETOOLS DEPLOYMENT COMPLETE! "
echo " Status of services: "
docker compose ps
echo "--------------------------------------------------------"