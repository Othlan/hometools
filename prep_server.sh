#!/bin/bash

# set -e: Exit immediately if a command exits with a non-zero status
# set -u: Treat unset variables as an error
set -eu

echo "--- 1. Updating System and Installing Prerequisites ---"
# Force non-interactive mode to avoid service restart pop-ups
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl ufw

echo "--- 2. Pre-configuring iptables-persistent (0-touch) ---"
# Pre-seed answers for iptables-persistent to bypass the interactive purple screens
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt install -y iptables-persistent

echo "--- 3. Setting up Docker Official GPG Key ---"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "--- 4. Adding Docker Repository to Apt Sources ---"
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "--- 5. Installing Docker Engine and Compose Plugin ---"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 6. Post-Installation: Adding User to Docker Group ---"
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

echo "--- 7. Verification ---"
docker --version
docker compose version

echo "--------------------------------------------------------"
echo " SERVER PREPARATION FINISHED SUCCESSFULLY! "
echo " Proceeding to hometools software installation... "
echo "--------------------------------------------------------"

# Check if hometools.sh exists before proceeding
if [ -f "./hometools.sh" ]; then
    chmod +x hometools.sh
    # Execute hometools.sh within the new docker group context
    sg docker -c "./hometools.sh"
else
    echo "ERROR: hometools.sh not found in the current directory!"
    exit 1
fi
