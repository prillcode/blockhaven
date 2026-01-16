# BlockHaven VPS Information

## Server Details

**VPS IP:** `5.161.69.191`

**SSH Access:** `ssh blockhaven_vps`

**Dokploy Installation Path:**
```
/etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/
```

**Server Data Directory:**
```
/etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server/data/
```

**Plugins Directory:**
```
/etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server/data/plugins/
```

**Scripts Directory:**
```
/etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server/scripts/
```

## Quick Access Commands

### Navigate to Server Directory
```bash
ssh blockhaven_vps
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server
```

### Docker Commands
```bash
# View server logs
ssh blockhaven_vps "docker logs blockhaven-mc -f"

# Access RCON
ssh blockhaven_vps "docker exec -i blockhaven-mc rcon-cli"

# Restart server
ssh blockhaven_vps "cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server && docker compose restart minecraft"

# Check running containers
ssh blockhaven_vps "docker ps"
```

### Install Plugins
```bash
# Run plugin installation script
ssh blockhaven_vps "cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server && bash INSTALL-PLUGINS.sh"

# Restart after installing plugins
ssh blockhaven_vps "cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server && docker compose restart minecraft"
```

### World Creation (After choosing seeds)
```bash
# Update seeds in create-worlds-rcon.sh locally, commit, push
# Then on VPS:
ssh blockhaven_vps "cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code && git pull origin main"
ssh blockhaven_vps "cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server && bash scripts/create-worlds-rcon.sh"
```

## Currently Installed Plugins

**Status:** 14/15 plugins loaded and working (as of Jan 2026)

**Core Plugins:**
- ✅ Essentials (player commands, homes, warps, etc.)
- ✅ Vault (economy/permissions API)
- ✅ LuckPerms (permissions management)

**Cross-Platform Support:**
- ✅ Geyser-Spigot (Bedrock player support)
- ✅ Floodgate (Bedrock authentication)
- ✅ ViaVersion (protocol version support)

**World Management:**
- ✅ Multiverse-Core (multiple worlds)
- ✅ Multiverse-Portals (portal linking)
- ✅ Multiverse-NetherPortals (nether portal routing)
- ✅ Multiverse-Inventories (per-world inventories)
- ✅ VoidGen (void world generator)

**Building & Protection:**
- ✅ WorldEdit (building tools)
- ✅ WorldGuard (region protection)
- ✅ UltimateLandClaim (land claiming)

**Not Loaded:**
- ❌ Jobs (economy jobs plugin - not currently needed)

## Configured Worlds

**Default World:** `spawn` (set via `level-name` in server.properties)

| World | Alias | Mode | Difficulty | Seed |
|-------|-------|------|------------|------|
| `spawn` | Spawn_Hub | Adventure | Peaceful | -268740982617589902 |
| `spawn_nether` | - | Survival | Normal | (linked to spawn) |
| `spawn_the_end` | - | Survival | Normal | (linked to spawn) |
| `creative_flat` | Creative_Plots | Creative | Peaceful | 8950076382012095193 |
| `creative_terrain` | Creative_Hills | Creative | Peaceful | 3017885471480990383 |
| `survival_easy` | SMP_Plains | Survival | Easy | 8377987092687320925 |
| `survival_normal` | SMP_Ravine | Survival | Normal | -3821186818266249955 |
| `survival_hard` | SMP_Cliffs | Survival | Hard | -8913466909937400889 |

**Note:** World data is stored in the Docker named volume `minecraft-data`, not in the repo's `./data` directory.

## Connection Info

**Java Edition:**
```
Server: 5.161.69.191:25565
```

**Bedrock Edition:**
```
Server: 5.161.69.191
Port: 19132
```

**Future (with domain):**
- Java: `play.bhsmp.com:25565`
- Bedrock: `play.bhsmp.com:19132`

## Completed Setup

1. ✅ VPS deployed and running
2. ✅ All plugins installed (14 working)
3. ✅ 8 worlds created with custom seeds
4. ✅ Spawn hub world configured
5. ✅ LuckPerms installed
6. ✅ Multiverse portal system ready

## Notes

- Dokploy auto-deploys when you push to GitHub `main` branch
- Server data persists in Docker volumes even after restarts
- Backups run every 2 hours automatically
- RCON password set via Dokploy environment variables
