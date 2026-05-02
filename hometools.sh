#!/bin/bash

set -e

echo "--- 1. Creating Directory Structure ---"
sudo mkdir -p /opt/hometools/data/metube

sudo chown -R $USER:docker /opt/hometools/data
sudo chmod -R 775 /opt/hometools/data

echo "--- 2. Configuring Firewall (UFW) ---"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 445/tcp
sudo ufw allow 139/tcp

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

echo "--- 3. Samba Credentials (In-Memory) ---"
read -rp "Set Samba Username: " SAMBA_USER
read -rsp "Set Samba Password: " SAMBA_PASS
echo ""

if [[ -z "$SAMBA_USER" || -z "$SAMBA_PASS" ]]; then
    echo "Error: Samba credentials cannot be empty."
    exit 1
fi

export SAMBA_USER=$SAMBA_USER
export SAMBA_PASS=$SAMBA_PASS

echo "--- 4. Checking Dependencies ---"
if ! command -v smbclient > /dev/null 2>&1; then
    echo "Installing samba-client for container healthchecks..."
    sudo apt update && sudo apt install -y samba-client
fi

echo "--- 5. Launching Services ---"
docker compose up -d

echo "--------------------------------------------------------"
echo " HOMETOOLS DEPLOYMENT COMPLETE! "
echo " Status of services: "
docker compose ps
echo "--------------------------------------------------------"
