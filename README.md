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
- `bookstack`: documentation and wiki platform
- `homarr`: dashboard for managing self-hosted services
- `portainer-agent`: agent for Portainer management (always installed for admin server integration)

## Ports
- MeTube: `http://HOST:8080`
- Stirling PDF: `http://HOST:8081`
- Bookstack: `http://HOST:6875`
- Homarr: `http://HOST:7575`
- Portainer Agent: `http://HOST:9001` (for agent connection)

## Requirements
- Ubuntu Server or Debian-based Linux
- `sudo` access
- Writable host directories: `/opt/hometools/data/metube`, `/opt/hometools/data/bookstack`, `/opt/hometools/data/homarr`

## What the scripts do
- `prep_server.sh`: installs Docker, Docker Compose plugin, and required packages, then runs `hometools.sh`.
- `hometools.sh`: creates the data directory, configures UFW, and starts the stack.
- `updateall.sh`: refreshes images and restarts services.

## Important notes
- For better security in production, use a reverse proxy with SSL/TLS and avoid exposing ports directly.
- If you choose Nginx reverse proxy, the installer restricts access to the proxy IP only for all services.
- Portainer Agent is always installed to enable management from the admin tools server.
- All SSL/TLS is handled by Nginx on the admin server.
- Use `./updateall.sh` to pull updates and restart containers.
