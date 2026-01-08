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

## Currently Installed Plugins (Phase 1)

**Auto-downloaded and WORKING (3 plugins):**
- ✅ Geyser-Spigot v2.9.2 (Bedrock support)
- ✅ Floodgate-Spigot v2.2.5 (Bedrock auth)
- ✅ ViaVersion v5.7.0 (Protocol support)

**Attempted to install (need version updates):**
- ⚠️ EssentialsX (file exists but not loading - may need newer version)
- ⚠️ Vault (file exists but not loading - may need newer version)
- ❌ Jobs Reborn (download link broken - 404 error)
- ❌ PlotSquared (download link broken - 404 error)

**Status:** 3/19 plugins working

**Next Steps:**
- Will add additional plugins as needed for each phase
- Phase 2 (LuckPerms) will require installing LuckPerms plugin
- Phase 3 (Jobs/Economy) will require fixing Jobs Reborn and Vault
- Phase 4 (World creation) will require Multiverse-Core
- Other plugins can be added on-demand

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
- Java: `play.blockhaven.gg:25565`
- Bedrock: `play.blockhaven.gg:19132`

## Next Steps

1. ✅ VPS deployed and running
2. ✅ Base plugins installed (7 total)
3. ⏳ Restart server to load new plugins
4. ⏳ Choose world seeds
5. ⏳ Create custom worlds
6. ⏳ Configure LuckPerms (Phase 2)

## Notes

- Dokploy auto-deploys when you push to GitHub `main` branch
- Server data persists in Docker volumes even after restarts
- Backups run every 2 hours automatically
- RCON password set via Dokploy environment variables
