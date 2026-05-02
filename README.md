## Quick Start (One-Click Install)
1. Clone the repository: `git clone https://github.com/Othlan/hometools` (or any directory)
2. `cd /hometools`
3. Make scripts executable: `chmod +x *.sh`
4. Run: `./prep_server.sh`
5. Follow prompts for Nginx (optional) and Samba credentials.

Expected outcome: Docker services are running and operational.

## Included services
- `metube`: media downloader / cataloger
- `stirling-pdf`: PDF processing service
- `samba`: Windows-compatible file share for download access

## Ports
- MeTube: `http://HOST:8080`
- Stirling PDF: `http://HOST:8081`
- Samba: `\\HOST\Downloads`

## Requirements
- Ubuntu Server (or Debian-based Linux)
- User with `sudo` access (for system setup and Docker commands)
- Writable host directory: `/hometools/metube` ```

## Scripts
- `prep_server.sh`: One-click setup—installs Docker, Compose plugin, adds user to docker group, then runs `hometools.sh`.
- `hometools.sh`: Configures data paths, firewall (with Nginx option), prompts for credentials, launches services, and shows status.
- `updateall.sh`: Updates all services by pulling latest images, prompts for Samba credentials, restarts services, and shows status.

## Notes
- All credentials and configuration values are entered interactively and are not stored in any file.
- The script asks if you want to use Nginx reverse proxy:
  - If yes: prompts for Nginx IP and restricts MeTube/Stirling PDF ports to that IP only.
  - If no: allows open access to MeTube (8080) and Stirling PDF (8081) from all IPs.
  - Default: Deny incoming, allow outgoing, allow 22/445/139
- Samba credentials are always prompted and not stored.
- To update services later, run: `./updateall.sh`
- Do not create or save a `.env` file for Samba credentials unless you explicitly want to manage them manually.
- If you run `docker compose` manually, you must set `SAMBA_USER` and `SAMBA_PASS` in the same shell session before starting the stack.
