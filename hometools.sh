#!/bin/bash
set -eu

echo "--------------------------------------------------------"
echo "--- 1. Creating Directory Structure --------------------"
echo "--------------------------------------------------------"
sudo mkdir -p /opt/hometools/data/{metube,bookstack,homarr,stirlingpdf,portainer_agent}
sudo chown -R root:docker /opt/hometools/data
sudo chmod -R 775 /opt/hometools/data

echo "--------------------------------------------------------"
echo "--- 2. Configuring Firewall ----------------------------"
echo "--------------------------------------------------------"
read -rp "Enter Nginx Proxy IP (Serv1): " NGINX_IP

# Reset DOCKER-USER chain
sudo iptables -F INPUT
sudo iptables -F DOCKER-USER

# 1. Essential: Allow SSH (Port 22) so you don't get locked out
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A DOCKER-USER -p tcp --dport 22 -j ACCEPT


# 2. Allow established traffic and loopback
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A DOCKER-USER -i lo -j ACCEPT
sudo iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


# 3. Define protected ports
PORTS=(8080 8081 6875 7575 9001)

# 4. Apply IP-specific rules
for PORT in "${PORTS[@]}"; do
    echo "Access granted for $NGINX_IP on port $PORT"
    sudo iptables -A DOCKER-USER -p tcp -s "$NGINX_IP" --dport "$PORT" -j ACCEPT
done

# 5. Drop all other traffic to these ports
sudo iptables -P INPUT DROP
sudo iptables -A DOCKER-USER -j DROP

echo "--------------------------------------------------------"
echo "--- 3. Generating Environment Variables ----------------"
echo "--------------------------------------------------------"
GEN_SECRET=$(openssl rand -base64 32)
cat > .env <<EOF
SECRET_ENCRYPTION_KEY=$GEN_SECRET
PUID=1000
PGID=1000
TZ=Europe/Bucharest
APP_DATA_PATH=/opt/hometools/data
BOOKSTACK_URL=https://your-domain.com
EOF

echo "--------------------------------------------------------"
echo "--- 4. Launching Services ------------------------------"
echo "--------------------------------------------------------"
docker compose up -d

echo "--------------------------------------------------------"
echo "--- 5. Persisting Firewall Rules -----------------------"
echo "--------------------------------------------------------"
sudo netfilter-persistent save

echo "DEPLOYMENT COMPLETE"
docker compose ps
