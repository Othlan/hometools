#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "============================================================"
echo " HomeTools - Update All Services"
echo "============================================================"

echo ""
echo "Gathering Samba Credentials..."

# Check if smbclient is available for validation
if ! command -v smbclient > /dev/null 2>&1; then
    echo "Warning: smbclient not found. Installing samba-client for credential validation..."
    sudo apt update && sudo apt install -y samba-client
fi

while true; do
    read -rp "Enter Samba Username: " SAMBA_USER
    read -rsp "Enter Samba Password: " SAMBA_PASS
    echo ""

    if [ -z "$SAMBA_USER" ] || [ -z "$SAMBA_PASS" ]; then
        echo "Error: Samba username and password are required."
        continue
    fi

    echo "Validating credentials against existing Samba account..."
    if smbclient //localhost/Downloads -U "$SAMBA_USER%$SAMBA_PASS" -c 'ls' > /dev/null 2>&1; then
        echo "Credentials validated successfully."
        break
    else
        echo "Credentials do not match the existing Samba account."
        echo "Warning: Proceeding will change the account and disconnect any current users."
        read -rp "Do you want to proceed with new credentials? (y/n): " PROCEED_NEW
        if [[ "$PROCEED_NEW" =~ ^[Yy]$ ]]; then
            echo "Proceeding with new credentials..."
            break
        else
            read -rp "Retry with correct existing credentials? (y/n): " RETRY
            if [[ "$RETRY" =~ ^[Nn]$ ]]; then
                echo "Exiting update."
                exit 1
            fi
            # Loop back to prompt
        fi
    fi
done

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
