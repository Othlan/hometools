## Quick Start
1. Clone the repository:
   `sudo git clone https://github.com/Othlan/hometools /opt/hometools`
2. `cd /opt/hometools`
3. `sudo chmod +x *.sh`
4. `sudo ./prep_server.sh`
5. Follow prompts for Nginx configuration. (Optional!)

## Services
- `metube`: media downloader / cataloger
- `stirling-pdf`: PDF processing service

## Ports
- MeTube: `http://HOST:8080`
- Stirling PDF: `http://HOST:8081`

## Requirements
- Ubuntu Server or Debian-based Linux
- `sudo` access
- Writable host directory: `/opt/hometools/data/metube`

## What the scripts do
- `prep_server.sh`: installs Docker, Docker Compose plugin, and required packages, then runs `hometools.sh`.
- `hometools.sh`: creates the data directory, configures UFW, and starts the stack.
- `updateall.sh`: refreshes images and restarts services.

## Important notes
- For better security in production, use a reverse proxy with SSL/TLS and avoid exposing 8080/8081 directly.
- If you choose Nginx reverse proxy, the installer restricts MeTube and Stirling PDF access to the proxy IP only.
- Use `./updateall.sh` to pull updates and restart containers.
