#!/bin/bash

set -e

echo "============================================================"
echo " HomeTools - Monthly Maintenance & Update"
echo "============================================================"

if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found in the current directory."
    echo "Please run this script from /opt/hometools"
    exit 1
fi

if ! command -v smbclient > /dev/null 2>&1; then
    echo "Installing samba-client for credential validation..."
    sudo apt update && sudo apt install -y samba-client
fi

while true; do
    echo ""
    read -rp "Enter Samba Username: " SAMBA_USER
    read -rsp "Enter Samba Password: " SAMBA_PASS
    echo ""

    if [[ -z "$SAMBA_USER" || -z "$SAMBA_PASS" ]]; then
        echo "Error: Credentials cannot be empty."
        continue
    fi

    echo "Validating credentials against running Samba service..."
    if smbclient //localhost/Downloads -U "$SAMBA_USER%$SAMBA_PASS" -c 'ls' > /dev/null 2>&1; then
        echo "Success: Credentials validated."
        break
    else
        echo "------------------------------------------------------------"
        echo "Warning: Credentials do NOT match the running Samba service."
        echo "Continuing will update the password and may kick off users."
        echo "------------------------------------------------------------"
        read -rp "Proceed with THESE new credentials? (y/n): " PROCEED
        if [[ "$PROCEED" =~ ^[Yy]$ ]]; then
            break
        else
            read -rp "Try again? (y/n): " RETRY
            if [[ ! "$RETRY" =~ ^[Yy]$ ]]; then
                echo "Update cancelled by user."
                exit 0
            fi
        fi
    fi
done

export SAMBA_USER=$SAMBA_USER
export SAMBA_PASS=$SAMBA_PASS

echo ""
echo "Step 1: Pulling latest images from registry..."
docker compose pull

echo "Step 2: Recreating containers with new images..."
docker compose up -d

echo "Step 3: Cleaning up orphaned images..."
docker image prune -f

echo ""
echo "============================================================"
echo " UPDATE COMPLETE! "
echo "============================================================"
docker compose ps
echo ""
