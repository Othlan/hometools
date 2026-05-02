#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "1. Creating Isolated Data Structure"
# Create the deep path for metube downloads
sudo mkdir -p /hometools/metube

# Set permissions so the 'docker' group (and our apps) can write there
sudo chown -R $USER:docker /hometools
sudo chmod -R 775 /hometools

echo "2. Configuring Firewall"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp          # SSH access
sudo ufw allow 445/tcp         # Samba
sudo ufw allow 139/tcp         # Samba NetBIOS

# Configure access for MeTube and Stirling PDF
read -rp "Do you want to use Nginx reverse proxy? (y/n): " USE_NGINX
if [[ "$USE_NGINX" =~ ^[Yy]$ ]]; then
    read -rp "Enter Nginx Proxy IP (e.g., 192.168.1.100): " NGINX_IP
    if [ -z "$NGINX_IP" ]; then
        echo "Error: Nginx IP is required when using reverse proxy."
        exit 1
    fi
    sudo ufw allow from $NGINX_IP to any port 8080 # MeTube
    sudo ufw allow from $NGINX_IP to any port 8081 # Stirling PDF
else
    echo "Allowing open access to MeTube (8080) and Stirling PDF (8081) from all IPs."
    sudo ufw allow 8080/tcp # MeTube
    sudo ufw allow 8081/tcp # Stirling PDF
fi

echo "y" | sudo ufw enable

echo "3. Security: Samba Credentials (In-Memory Only)"
# These variables exist only during this script run and are not written to disk
read -rp "Enter Samba Username: " SAMBA_USER
read -rsp "Enter Samba Password: " SAMBA_PASS
echo ""

if [ -z "$SAMBA_USER" ] || [ -z "$SAMBA_PASS" ]; then
    echo "Error: Samba username and password are required."
    exit 1
fi

export SAMBA_USER SAMBA_PASS

echo "4. Launching HomeTools YAML"
docker compose up -d

echo "--------------------------------------------------------"
echo " HOMETOOLS DEPLOYMENT COMPLETE! "
echo " Checking service status..."
docker compose ps
echo "--------------------------------------------------------"
