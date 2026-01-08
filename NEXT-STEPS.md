# BlockHaven - Next Steps

**Last Updated:** January 7, 2026

---

## Current Status

✅ **Phase 1 Complete:**
- Docker foundation deployed to VPS
- Paper 1.21.11 server running
- Phase 1 plugins installed and working
- Custom MOTD and server icon configured
- Server accessible at `5.161.69.191:25565`

**Ready for:** Domain setup, world creation, and Phase 2 configuration

---

## Immediate Next Steps

### 1. World Creation (Ready to Execute!)

**Status:** Scripts and plugins prepared, ready for seed selection and execution

**Quick Start:**
1. Gather your 4 world seeds (see section 2 below)
2. Follow [mc-server/WORLD-SETUP-SUMMARY.md](mc-server/WORLD-SETUP-SUMMARY.md) for 3-step process
3. Detailed guide: [mc-server/CREATE-WORLDS-GUIDE.md](mc-server/CREATE-WORLDS-GUIDE.md)

**What's Ready:**
- ✅ Multiverse-Core, Multiverse-Portals, Multiverse-Inventories added to install script
- ✅ VoidGen added for spawn world
- ✅ Automated creation script: [mc-server/scripts/create-worlds-rcon.sh](mc-server/scripts/create-worlds-rcon.sh)
- ✅ LEVEL=spawn already configured in docker-compose.yml

**Deliverables:**
- [ ] Run INSTALL-PLUGINS.sh on VPS to add Multiverse + VoidGen
- [ ] Verify plugins loaded with `/plugins`
- [ ] Add your seeds to create-worlds-rcon.sh
- [ ] Run bash scripts/create-worlds-rcon.sh
- [ ] Verify all 6 worlds created with `/mv list`

---

### 2. Domain & DNS Setup (Do After World Creation)

**Goal:** Configure `blockhaven.gg` domain with Cloudflare DNS

#### DNS Records (Cloudflare)

**Marketing Website (Proxied for DDoS protection):**
```
Type: A
Name: @
Content: 5.161.69.191
Proxy status: ☁️ Proxied (Orange Cloud)
TTL: Auto
```

**Minecraft Server (DNS Only - required for game traffic):**
```
Type: A
Name: play
Content: 5.161.69.191
Proxy status: 🌐 DNS Only (Gray Cloud)
TTL: Auto
```

**Important Notes:**
- ✅ Website traffic CAN use Cloudflare proxy (HTTP/HTTPS)
- ❌ Minecraft traffic CANNOT use Cloudflare proxy (ports 25565, 19132)
- The `play` subdomain MUST be "DNS Only" for Minecraft to work
- Your VPS IP will be visible via `play.blockhaven.gg` (this is normal)

#### DDoS Protection Strategy

**Current Setup (Good for starting):**
- Website: Protected by Cloudflare proxy
- Minecraft: Exposed (relies on Hetzner's basic DDoS mitigation)
- Risk: Low for small servers

**Future Option (When you grow):**
- Add TCPShield (free tier): https://tcpshield.com/
- Provides Minecraft-specific DDoS protection
- Hides your real VPS IP from players
- Update DNS: `play.blockhaven.gg` → TCPShield IP → Your VPS

#### Player Connection Info

After DNS setup, players connect with:
- **Java Edition:** `play.blockhaven.gg`
- **Bedrock Edition:** `play.blockhaven.gg` port `19132`

**Deliverables:**
- [ ] Purchase/register `blockhaven.gg` domain
- [ ] Add domain to Cloudflare
- [ ] Create `A` record for `@` (proxied)
- [ ] Create `A` record for `play` (DNS only)
- [ ] Wait for DNS propagation (5-30 minutes)
- [ ] Test connection: `play.blockhaven.gg`
- [ ] Update MOTD in docker-compose.yml to show `play.blockhaven.gg`

### 3. Choose World Seeds (Before Running World Creation)

**Goal:** Select Minecraft seeds for the 6 main worlds

**Worlds that need seeds:**
1. **survival_easy** - Village-heavy, flatter terrain (normal generation)
2. **survival_hard** - Mountainous/amplified terrain (AMPLIFIED type)
3. **creative_terrain** - Natural landscape for large plots (normal generation)
4. **resource** - Standard world (any seed, resets monthly)
5. **creative_flat** - Superflat (no seed needed, auto-generated flat)
6. **spawn** - Void world (no seed needed, uses VoidGen)

**Seeds Needed:** 4 total (survival_easy, survival_hard, creative_terrain, resource)

**Seed Resources:**
- https://www.chunkbase.com/apps/seed-map
- r/minecraftseeds
- https://www.minecraft-seeds.com/

**Where to Add Seeds:**
- Update [mc-server/scripts/create-worlds-rcon.sh](mc-server/scripts/create-worlds-rcon.sh) lines 7-10
- See [mc-server/WORLD-SETUP-SUMMARY.md](mc-server/WORLD-SETUP-SUMMARY.md) for details

**Deliverables:**
- [ ] Choose seed for survival_easy
- [ ] Choose seed for survival_hard
- [ ] Choose seed for creative_terrain
- [ ] Choose seed for resource (or use any random seed)
- [ ] Update create-worlds-rcon.sh with your seeds

---

## Phase 2: LuckPerms Configuration

**Estimated Time:** 2-3 hours

**Goal:** Set up complete rank hierarchy with permissions for all donation tiers and staff roles.

### Tasks

#### 2.1 Configure LuckPerms Groups

**Access LuckPerms editor:**
```bash
# In-game or via RCON
/lp editor
```

**Create Staff Ranks:**
```bash
/lp creategroup helper
/lp creategroup moderator
/lp creategroup admin

# Set up inheritance
/lp group helper parent add default
/lp group moderator parent add helper
/lp group admin parent add moderator
```

**Create Donor Ranks:**
```bash
/lp creategroup friend
/lp creategroup family
/lp creategroup vip
/lp creategroup lifetime_vip

# Set up inheritance
/lp group friend parent add default
/lp group family parent add friend
/lp group vip parent add family
/lp group lifetime_vip parent add vip
```

#### 2.2 Assign Permissions

**Reference:** [mc-server/docs/MONETIZATION.md](mc-server/docs/MONETIZATION.md)

**Key permissions to configure:**

**Friend Rank ($4.99/month):**
- Chat colors: `essentials.nick.color`
- 5 plots: `plotsquared.plot.limit.5`
- 3 homes: `essentials.sethome.multiple.friend`

**Family Rank ($9.99/month):**
- Custom nickname: `essentials.nick`
- 1 private world: `privateworld.create.1`
- 10 plots: `plotsquared.plot.limit.10`
- 5 homes: `essentials.sethome.multiple.family`

**VIP Rank ($19.99/month):**
- 3 private worlds: `privateworld.create.3`
- 20 plots: `plotsquared.plot.limit.20`
- 10 homes: `essentials.sethome.multiple.vip`

**Lifetime VIP ($99.99 one-time):**
- Unlimited plots: `plotsquared.plot.unlimited`
- 20 homes: `essentials.sethome.multiple.lifetime`

**Staff Permissions:**
- Helper: `/warn`, `/mute`, `/kick`
- Moderator: + `/ban`, `/vanish`, CoreProtect inspection
- Admin: Full access

**Deliverables:**
- [ ] All 9 groups created (4 staff, 5 donor)
- [ ] Permission nodes assigned per rank
- [ ] Inheritance configured correctly
- [ ] Export configuration: `/lp export`

---

## Phase 3: Jobs Reborn + Economy

**Estimated Time:** 2 hours

**Goal:** Configure jobs with world-specific payouts and balanced economy.

**See:** [blockhaven-planning-doc.md](blockhaven-planning-doc.md#phase-3-jobs-reborn--economy-balancing)

**Deliverables:**
- [ ] All 7 jobs configured
- [ ] World multipliers set (survival_hard = 1.5x)
- [ ] Economy settings configured
- [ ] Test job earnings in each world

---

## Phase 4: Multiverse-Inventories & PlotSquared

**Estimated Time:** 2 hours

**Goal:** Configure inventory groups and creative plot areas.

### Multiverse-Inventories Configuration

**File:** `plugins/Multiverse-Inventories/groups.yml`

```yaml
groups:
  survival:
    worlds:
      - survival_easy
      - survival_hard
      - resource
      - spawn
    shares:
      - inventory
      - ender_chest

  creative_flat:
    worlds:
      - creative_flat
    shares:
      - all

  creative_terrain:
    worlds:
      - creative_terrain
    shares:
      - all
```

Apply: `/mvinv reload`

### PlotSquared Setup

```bash
# Creative Flat - 64x64 plots
/plot area create creative_flat

# Creative Terrain - 128x128 plots
/plot area create creative_terrain
```

**Deliverables:**
- [ ] Inventory groups configured
- [ ] PlotSquared areas created
- [ ] Test inventory sharing/isolation

---

## Phase 5-9: Continue with Original Plan

See sections in [blockhaven-planning-doc.md](blockhaven-planning-doc.md):
- Phase 5: GriefPrevention Multi-World Config
- Phase 6: Private Worlds System (Custom Skript)
- Phase 7: Monetization Setup (Tebex)
- Phase 8: Safety & Moderation (ChatSentry)
- Phase 9: Polish & Launch (Spawn hub, Discord, beta testing)

---

## Production Hardening Checklist

- [ ] Firewall configured (UFW)
- [ ] Fail2ban installed
- [ ] UptimeRobot monitoring set up
- [ ] S3/cloud backups configured
- [ ] SSL/TLS for BlueMap (nginx reverse proxy)
- [ ] Resource world reset cron job (monthly)
- [ ] Discord webhooks for alerts

---

## Quick Reference

### Connection Info

**Current (IP-based):**
- Java: `5.161.69.191:25565`
- Bedrock: `5.161.69.191:19132`

**After DNS setup:**
- Java: `play.blockhaven.gg`
- Bedrock: `play.blockhaven.gg` port `19132`

### VPS Access

```bash
# SSH to VPS
ssh blockhaven_vps

# Navigate to server
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code/mc-server

# View logs
docker logs blockhaven-mc -f

# Access RCON
docker exec -i blockhaven-mc rcon-cli

# Restart server
docker compose restart minecraft
```

### Key Documentation

| File | Purpose |
|------|---------|
| [VPS-INFO.md](VPS-INFO.md) | VPS access and deployment commands |
| [blockhaven-planning-doc.md](blockhaven-planning-doc.md) | Complete project planning |
| [mc-server/docs/SETUP.md](mc-server/docs/SETUP.md) | Deployment and troubleshooting |
| [mc-server/docs/WORLDS.md](mc-server/docs/WORLDS.md) | World setup and configuration |
| [mc-server/docs/MONETIZATION.md](mc-server/docs/MONETIZATION.md) | Tebex packages and pricing |

---

**Good luck with BlockHaven! 🚀**

*Remember: Build incrementally, test thoroughly, and have fun!*
