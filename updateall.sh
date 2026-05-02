#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "============================================================"
echo " HomeTools - Update All Services"
echo "============================================================"

echo ""
echo "Gathering Samba Credentials..."
read -rp "Enter Samba Username: " SAMBA_USER
read -rsp "Enter Samba Password: " SAMBA_PASS
echo ""

if [ -z "$SAMBA_USER" ] || [ -z "$SAMBA_PASS" ]; then
    echo "Error: Samba username and password are required."
    exit 1
fi

export SAMBA_USER SAMBA_PASS

echo ""
echo "Pulling latest images and updating services..."
sudo docker compose pull
sudo docker compose up -d

echo ""
echo "============================================================"
echo " Services Updated Successfully! "
echo "============================================================"
echo ""
sudo docker compose ps
echo ""
