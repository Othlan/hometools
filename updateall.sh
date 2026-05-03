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

if ! command -v docker > /dev/null 2>&1; then
    echo "Error: Docker is not installed. Run prep_server.sh first."
    exit 1
fi
if ! docker compose version > /dev/null 2>&1; then
    echo "Error: Docker Compose is not available."
    exit 1
fi

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