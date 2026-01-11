# BlockHaven Minecraft Server - Bedrock Mobile Connection Issue

## Context

I'm running a Paper 1.21.4 Minecraft server with Geyser/Floodgate for cross-platform play (Java + Bedrock). The server is Docker-based on a Hetzner VPS using the itzg/minecraft-server image.

**Server address:** play.bhsmp.com (port 19132 for Bedrock)

**Key plugins installed:**
- Geyser-Spigot + Floodgate (Bedrock support)
- Multiverse-Core
- Multiverse-Portals
- Multiverse-Inventories
- GriefPrevention
- LuckPerms
- EssentialsX

## Problem

After adding Multiverse-Portals and configuring portals between worlds, mobile Bedrock clients get stuck on "Loading resource packs" screen and never connect. 

**What works:**
- Java Edition clients connect fine
- OP user on laptop (Java) can use portals and `/mvtp` commands successfully
- Mobile client shows "Low ping" in server list

**What doesn't work:**
- Bedrock mobile client hangs indefinitely on "Loading resource packs"
- This started after adding Multiverse-Portals

## Proposed Troubleshooting Steps

1. **Check server logs during mobile connection attempt:**
   ```bash
   docker-compose logs -f minecraft | grep -i geyser
   ```

2. **Check Geyser config** (`plugins/Geyser-Spigot/config.yml`):
   ```yaml
   force-resource-packs: false
   xbox-achievements-enabled: true
   add-non-bedrock-items: false  # Disables auto-generated resource pack
   resource-pack-download-url: ""  # Should be empty if not using custom packs
   ```

3. **Check server.properties for forced resource packs:**
   ```properties
   require-resource-pack=false
   resource-pack=
   resource-pack-sha1=
   ```

4. **Test if Multiverse-Portals is the culprit:**
   - Disable the plugin temporarily (rename .jar to .disabled)
   - Restart server and test mobile connection
   - If it works, the issue is portal packets confusing Bedrock clients

5. **Try Multiverse reload:**
   ```bash
   /mv reload
   ```

## What I Need Help With

- Diagnosing the root cause from server logs
- Fixing Geyser/Multiverse-Portals compatibility if that's the issue
- Alternative portal solutions if Multiverse-Portals doesn't play well with Bedrock clients
