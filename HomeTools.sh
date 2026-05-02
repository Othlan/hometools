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

# Allow traffic from Nginx Proxy Manager VM
# IMPORTANT: Replace <IP> with the actual IP of your Nginx Proxy Manager
sudo ufw allow from <IP> to any port 8080 # MeTube
sudo ufw allow from <IP> to any port 8081 # Stirling PDF

echo "y" | sudo ufw enable

echo "3. Security: Samba Credentials (In-Memory Only)"
# These variables exist only during this session and won't be saved to disk
read -p "Enter Samba Username: " SAMBA_USER
read -s -p "Enter Samba Password: " SAMBA_PASS
echo ""


echo "4. Launching HomeTools YAML"
docker compose up -d

echo "--------------------------------------------------------"
echo " HOMETOOLS DEPLOYMENT COMPLETE! "
echo " MeTube: Port 8080 | Stirling PDF: Port 8081 "
echo " Samba Share: \\<IP>\\Downloads "
echo "--------------------------------------------------------"