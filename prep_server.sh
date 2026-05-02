#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- 1. Updating System and Installing Prerequisites ---"
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl

echo "--- 2. Setting up Docker Official GPG Key ---"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "--- 3. Adding Docker Repository to Apt Sources ---"
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "--- 4. Installing Docker Engine and Compose Plugin ---"
sudo apt update
# docker-compose-v2 is the current recommended package for 'docker compose' command
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 5. Post-Installation: Adding User to Docker Group ---"
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

echo "--- 6. Verification ---"
docker --version
docker compose version

echo "--------------------------------------------------------"
echo " SETUP FINISHED! "
echo " IMPORTANT: I'll now start installing the software! "
echo "--------------------------------------------------------"
sg docker -c "./hometools.sh"
