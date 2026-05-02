# HomeTools

A lightweight Docker-based home tools server for media and file-sharing utilities.

## Included services
- `metube`: media downloader / cataloger
- `stirling-pdf`: PDF processing service
- `samba`: Windows-compatible file share for download access

## Ports
- MeTube: `http://HOST:8080`
- Stirling PDF: `http://HOST:8081`
- Samba: `\\HOST\Downloads`

## Requirements
- Docker Engine and Compose plugin installed
- Linux host with `sudo` access
- Writable host directory: `/hometools/metube`

## Setup
1. Create the data directory:
   ```bash
   sudo mkdir -p /hometools/metube
   sudo chown -R $USER:docker /hometools
   sudo chmod -R 775 /hometools
   ```
2. Run the setup script and enter Samba credentials when prompted:
   ```bash
   ./HomeTools.sh
   ```

## Scripts
- `Prep_Server.sh`: installs Docker, the Compose plugin, adds the current user to the `docker` group, and then launches `HomeTools.sh`.
- `HomeTools.sh`: creates the host data path, configures UFW rules (with option for Nginx proxy or open access), prompts once for Samba credentials, and starts the Docker stack.

## Notes
- All credentials and configuration values are entered interactively and are not stored in any file.
- The script asks if you want to use Nginx reverse proxy:
  - If yes: prompts for Nginx IP and restricts MeTube/Stirling PDF ports to that IP only.
  - If no: allows open access to MeTube (8080) and Stirling PDF (8081) from all IPs.
- Samba credentials are always prompted and not stored.
- Do not create or save a `.env` file for Samba credentials unless you explicitly want to manage them manually.
- If you run `docker compose` manually, you must set `SAMBA_USER` and `SAMBA_PASS` in the same shell session before starting the stack.

