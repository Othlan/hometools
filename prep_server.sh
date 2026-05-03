#!/bin/bash
set -eu

echo "--- 1. Updating System and Installing Prerequisites ---"
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl ufw gnupg lsb-release

echo "--- 2. Pre-configuring iptables-persistent ---"
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt install -y iptables-persistent

echo "--- 3. Setting up Docker GPG Key ---"
sudo rm -f /etc/apt/keyrings/docker.asc
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://docker.com -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "--- 4. Adding Docker Repository ---"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://docker.com \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "--- 5. Installing Docker Engine ---"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 6. Adding User to Docker Group ---"
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"

echo "--- 7. Verification ---"
docker --version
docker compose version

echo "--- 8. Executing Hometools Setup ---"
if [ -f "./hometools.sh" ]; then
    chmod +x hometools.sh
    exec sg docker -c "./hometools.sh"
else
    echo "ERROR: hometools.sh not found!"
    exit 1
fi
