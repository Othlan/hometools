#!/bin/bash
set -eu

echo "--------------------------------------------------------"
echo "--- 1. Updating System and Installing Prerequisites ----"
echo "--------------------------------------------------------"
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl

echo "--------------------------------------------------------"
echo "--- 2. Pre-configuring iptables-persistent -------------"
echo "--------------------------------------------------------"
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt install -y iptables-persistent

echo "--------------------------------------------------------"
echo "--- 3. Setting up Docker Official GPG Key --------------"
echo "--------------------------------------------------------"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "--------------------------------------------------------"
echo "--- 4. Adding Docker Repository to Apt Sources ---------"
echo "--------------------------------------------------------"
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "--------------------------------------------------------"
echo "--- 5. Installing Docker Engine and Compose Plugin -----"
echo "--------------------------------------------------------"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--------------------------------------------------------"
echo "--- 6. Adding User to Docker Group ---------------------"
echo "--------------------------------------------------------"
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"

echo "--------------------------------------------------------"
echo "--- 7. Verification ------------------------------------"
echo "--------------------------------------------------------"
docker --version
docker compose version

echo "--------------------------------------------------------"
echo "--- 8. Executing Hometools Setup -----------------------"
echo "--------------------------------------------------------"
if [ -f "./hometools.sh" ]; then
    chmod +x hometools.sh
    exec sg docker -c "./hometools.sh"
else
    echo "ERROR: hometools.sh not found!"
    exit 1
fi
