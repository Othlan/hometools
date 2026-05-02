set -e

echo "--- Stage 2: Deploying HomeTools Services ---"

# 1. Prepare Directories
# We use sudo for mkdir but chown to our user so Docker can write there
sudo mkdir -p /data/Company/Downloads
sudo mkdir -p /data/Company/StirlingPDF
sudo chown -R $USER:$USER /data/Company

# 2. Firewall Configuration (UFW)
echo "--- Configuring Firewall ---"
sudo ufw default deny incoming
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 445/tcp  # Samba
# Allow Nginx Proxy Manager (VM4) to access our tools
# Replace <VM4_IP> with the actual IP of your NPM VM
sudo ufw allow from <VM4_IP> to any port 8080 

echo "y" | sudo ufw enable

# 3. Launch Containers
echo "--- Starting Docker Compose ---"
# This will now run WITHOUT sudo because of the 'sg docker' context
docker compose up -d

echo "--------------------------------------------------------"
echo " HOMETOOLS DEPLOYMENT COMPLETE! "
echo "--------------------------------------------------------"