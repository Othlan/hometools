#!/bin/bash

# set -e: Exit immediately if a command exits with a non-zero status
# set -u: Treat unset variables as an error
set -eu

echo "--- 1. Creating Directory Structure ---"
sudo mkdir -p /opt/hometools/data/{metube,bookstack,homarr,stirlingpdf,portainer_agent}

# Setting ownership to root and docker group for system-wide persistence
sudo chown -R root:docker /opt/hometools/data
sudo chmod -R 775 /opt/hometools/data

echo "--- 2. Configuring Firewall (UFW) ---"
if ! command -v ufw > /dev/null 2>&1; then
    echo "Installing UFW..."
    sudo apt update
    sudo apt install -y ufw
fi

# Basic UFW hardening
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'Allow SSH'

# Detect the primary network interface
IFACE=$(ip route | grep default | awk '{print $5}')
echo "Detected network interface: $IFACE"

read -rp "Are you using a Nginx Proxy server? (y/n): " USE_NGINX
if [[ "$USE_NGINX" =~ ^[Yy]$ ]]; then
    read -rp "Enter Nginx Proxy IP (e.g., 192.168.1.100): " NGINX_IP
    if [[ -z "$NGINX_IP" ]]; then
        echo "Error: Nginx IP is required for restricted access. Exiting."
        exit 1
    fi

    echo "--- Applying Advanced Docker-User Security Rules ---"
    # Flush the DOCKER-USER chain to avoid duplicate rules on re-runs
    sudo iptables -F DOCKER-USER

    # Define ports to protect
    PORTS=(8080 8081 6875 7575 9001)

    for PORT in "${PORTS[@]}"; do
        # 1. Allow the Nginx Proxy IP
        sudo iptables -I DOCKER-USER -i "$IFACE" -s "$NGINX_IP" -p tcp --dport "$PORT" -j ACCEPT
        # 2. Drop everyone else (This rule goes below the ACCEPT rule because we use -I)
        sudo iptables -I DOCKER-USER -i "$IFACE" ! -s "$NGINX_IP" -p tcp --dport "$PORT" -j DROP
    done
    
    echo "Firewall restricted to Nginx Proxy at $NGINX_IP."
else
    echo "Warning: Allowing public access to all service ports."
    sudo ufw allow 8080/tcp
    sudo ufw allow 8081/tcp
    sudo ufw allow 6875/tcp
    sudo ufw allow 7575/tcp
    sudo ufw allow 9001/tcp
fi

echo "--- 2.5. Generating Environment Variables ---"
# Generate unique secret and gather system IDs
GEN_SECRET=$(openssl rand -base64 32)
cat > .env <<EOF
SECRET_ENCRYPTION_KEY=$GEN_SECRET
PUID=1000
PGID=1000
TZ=Europe/Bucharest
APP_DATA_PATH=/opt/hometools/data
BOOKSTACK_URL=http://localhost:6875
EOF

chmod 640 .env
echo "Environment file created (.env)"

# Enable UFW (force avoids the 'Command may disrupt existing ssh connections' prompt)
echo "y" | sudo ufw --force enable

echo "--- 3. Launching Services ---"
# Check if Docker is ready
if ! docker compose version > /dev/null 2>&1; then
    echo "Error: Docker Compose is not available. Please run prep_server.sh first."
    exit 1
fi

# Pull and start containers in detached mode
docker compose up -d

echo "--- 4. Saving Security Rules ---"
# Ensure iptables rules survive reboot via netfilter-persistent (installed in prep_server.sh)
sudo netfilter-persistent save

echo "--------------------------------------------------------"
echo " HOMETOOLS DEPLOYMENT COMPLETE! "
echo " Services are running and secured. "
echo "--------------------------------------------------------"
docker compose ps
