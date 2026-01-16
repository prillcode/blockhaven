# BlockHaven Local Server Setup

Run a local copy of the BlockHaven Minecraft server for family LAN play or development.

## Quick Start (Fresh Server)

If you just want a fresh local server without importing VPS data:

```bash
cd mc-server
docker compose -f docker-compose.local.yml up -d
```

## Import VPS Data to Local

To replicate your VPS server locally (preserving worlds, configs, and player data):

### Step 1: Export Data from VPS

SSH into the VPS and run the export script:

```bash
ssh blockhaven_vps
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server
bash scripts/export-server-data.sh
exit
```

### Step 2: Download the Export

```bash
cd mc-server
scp blockhaven_vps:/tmp/blockhaven-export.tar.gz ./
```

### Step 3: Import to Local Docker Volume

```bash
bash scripts/import-server-data.sh blockhaven-export.tar.gz
```

### Step 4: Start Local Server

```bash
docker compose -f docker-compose.local.yml up -d
```

## Connection Info

| Platform | Address |
|----------|---------|
| Java (localhost) | `localhost:25565` |
| Java (LAN/Tailscale) | `<your-ip>:25565` |
| Bedrock (localhost) | `localhost:19132` |
| Bedrock (LAN/Tailscale) | `<your-ip>:19132` |

## Useful Commands

```bash
# View server logs
docker logs -f blockhaven-local

# Access RCON console
docker exec -i blockhaven-local rcon-cli

# Stop server
docker compose -f docker-compose.local.yml down

# Restart server
docker compose -f docker-compose.local.yml restart

# List loaded plugins
docker exec -i blockhaven-local rcon-cli plugins

# List worlds
docker exec -i blockhaven-local rcon-cli mv list
```

## Data Location

Local server data is stored in the Docker named volume `mc-server_blockhaven-local-data`.

To inspect the volume:
```bash
docker volume inspect mc-server_blockhaven-local-data
```

To access files inside the volume:
```bash
# List files
docker run --rm -v mc-server_blockhaven-local-data:/data alpine ls -la /data

# Copy a file out
docker run --rm -v mc-server_blockhaven-local-data:/data -v $(pwd):/out alpine cp /data/server.properties /out/
```

## Differences from VPS

| Setting | VPS | Local |
|---------|-----|-------|
| Memory | 6GB | 4GB (adjustable) |
| Online Mode | true | false (allows offline clients) |
| Max Players | 100 | 20 |
| View Distance | 10 | 12 |
| Container Name | `blockhaven-mc` | `blockhaven-local` |
| Volume Name | `minecraft-data` | `blockhaven-local-data` |
| RCON Password | (from env) | `localdev` |

## Syncing Changes

The local and VPS servers are independent. If you make changes locally that you want on the VPS (or vice versa), you'll need to:

1. Export from the source server
2. Import to the destination server

**Warning:** Importing will overwrite existing world data. Back up first if needed.

## Troubleshooting

### Server won't start
Check logs: `docker logs blockhaven-local`

### Can't connect from another device
- Ensure your firewall allows ports 25565 and 19132
- If using Tailscale, use your Tailscale IP
- Check that `ONLINE_MODE` is set appropriately

### Worlds not loading
Verify Multiverse-Core loaded: `docker exec -i blockhaven-local rcon-cli plugins`
Then list worlds: `docker exec -i blockhaven-local rcon-cli mv list`

### Permission errors
The container runs as UID 1000. If you have permission issues, try:
```bash
docker exec blockhaven-local chown -R 1000:1000 /data
```
