#!/bin/bash
set -eu

echo "--- 1. Creating Directory Structure ---"
sudo mkdir -p /opt/hometools/data/{metube,bookstack,homarr,stirlingpdf,portainer_agent}
sudo chown -R root:docker /opt/hometools/data
sudo chmod -R 775 /opt/hometools/data

echo "--- 2. Configuring Firewall ---"
read -rp "Enter Nginx Proxy IP (Serv1): " NGINX_IP

# Reset DOCKER-USER chain
sudo iptables -F DOCKER-USER

# 1. Allow established traffic and loopback
sudo iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A DOCKER-USER -i lo -j ACCEPT

# 2. Define protected ports
PORTS=(8080 8081 6875 7575 9001)

# 3. Apply IP-specific rules
for PORT in "${PORTS[@]}"; do
    # Accept only from Nginx Proxy
    sudo iptables -A DOCKER-USER -p tcp -s "$NGINX_IP" --dport "$PORT" -j ACCEPT
    # Drop all others
    sudo iptables -A DOCKER-USER -p tcp --dport "$PORT" -j DROP
done

# 4. Enable UFW for system ports (SSH)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
echo "y" | sudo ufw --force enable

echo "--- 3. Generating Environment ---"
GEN_SECRET=$(openssl rand -base64 32)
cat > .env <<EOF
SECRET_ENCRYPTION_KEY=$GEN_SECRET
PUID=1000
PGID=1000
TZ=Europe/Bucharest
APP_DATA_PATH=/opt/hometools/data
BOOKSTACK_URL=https://your-domain.com
EOF

echo "--- 4. Launching Services ---"
docker compose up -d

echo "--- 5. Persisting Firewall Rules ---"
sudo netfilter-persistent save

echo "DEPLOYMENT COMPLETE"
docker compose ps
