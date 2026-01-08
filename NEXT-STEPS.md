# BlockHaven - Next Steps

**Last Updated:** January 7, 2026

---

## Current Status

✅ **Phase 1 Complete:** Docker foundation, plugin stack validation, comprehensive documentation

**Ready for:** Local testing and Phase 2 configuration

---

## Immediate Next Steps (Before Phase 2)

### 1. Test Local Deployment

**Estimated Time:** 30 minutes

```bash
cd /home/aaronprill/projects/blockhaven/mc-server

# Configure environment
cp .env.example .env
nano .env  # Set RCON_PASSWORD and SERVER_OPS=PRLLAGER207

# Start server
docker compose up -d

# Monitor startup (wait for "Done! For help, type help")
docker compose logs -f minecraft
```

**What to verify:**
- [ ] Server starts without errors
- [ ] All 25+ plugins load successfully (check with `/plugins`)
- [ ] Java Edition connection works (localhost:25565)
- [ ] Bedrock Edition connection works (localhost:19132)
- [ ] RCON access works (`docker exec -it blockhaven-mc rcon-cli`)
- [ ] Geyser/Floodgate properly configured (Bedrock players can join)

**Troubleshooting:**
- See [mc-server/docs/SETUP.md](mc-server/docs/SETUP.md) for common issues
- Check plugin logs: `docker-compose logs minecraft | grep -i error`

---

### 2. Push to GitHub

```bash
# Already committed, just push
git push origin main
```

Then pull on your other dev laptop and repeat testing there.

---

## Phase 2: LuckPerms Configuration

**Estimated Time:** 2-3 hours

**Goal:** Set up complete rank hierarchy with permissions for all donation tiers and staff roles.

### Tasks

#### 2.1 Configure LuckPerms Groups

**File:** Access via LuckPerms web editor (`/lp editor`) or edit exported YAML

1. **Create Staff Ranks:**
   ```bash
   /lp creategroup helper
   /lp creategroup moderator
   /lp creategroup admin

   # Set up inheritance
   /lp group helper parent add default
   /lp group moderator parent add helper
   /lp group admin parent add moderator
   ```

2. **Create Donor Ranks:**
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

**Reference:** [mc-server/docs/MONETIZATION.md](mc-server/docs/MONETIZATION.md) - See "LuckPerms Permission Nodes" section

**Key permissions to configure:**

**Friend Rank:**
- Chat colors: `essentials.nick.color`
- 5 plots: `plotsquared.plot.limit.5`
- 3 homes: `essentials.sethome.multiple.friend`
- Particle effects: `minecraft.particle.effect`

**Family Rank:**
- Custom nickname: `essentials.nick`
- 1 private world: `privateworld.create.1`
- 10 plots: `plotsquared.plot.limit.10`
- 5 homes: `essentials.sethome.multiple.family`

**VIP Rank:**
- 3 private worlds: `privateworld.create.3`
- Fly in spawn: `essentials.fly` (world context: `spawn`)
- 20 plots: `plotsquared.plot.limit.20`
- 10 homes: `essentials.sethome.multiple.vip`

**Lifetime VIP:**
- Unlimited plots: `plotsquared.plot.unlimited`
- 20 homes: `essentials.sethome.multiple.lifetime`
- Founder tag: `blockhaven.founder`

**Staff Permissions:**
- Helper: `/warn`, `/mute`, `/kick`
- Moderator: + `/ban`, `/vanish`, CoreProtect inspection
- Admin: Full access (`*` or specific admin permissions)

#### 2.3 Set Default Group

```bash
/lp group default permission set minecraft.command.help true
/lp group default permission set essentials.spawn true
/lp group default permission set essentials.home true
/lp group default permission set essentials.sethome true
```

#### 2.4 Export Configuration

```bash
/lp export
# Creates export file in plugins/LuckPerms/exports/

# Copy to version control
cp data/plugins/LuckPerms/exports/latest.json.gz plugins/configs/LuckPerms/groups-export.json.gz
```

**Deliverables:**
- [ ] All 9 groups created (4 staff, 5 donor)
- [ ] Permission nodes assigned per rank
- [ ] Inheritance configured correctly
- [ ] Default group has basic permissions
- [ ] Configuration exported to `plugins/configs/LuckPerms/`

---

## Phase 3: Jobs Reborn + Economy Balancing

**Estimated Time:** 2 hours

**Goal:** Configure job definitions with world-specific payout multipliers and balanced economy.

### Tasks

#### 3.1 Configure Job Definitions

**File:** `plugins/configs/Jobs/jobConfig.yml`

**Jobs to configure:**
1. **Miner** - Mining ores, stone, coal
2. **Farmer** - Farming crops, breeding animals
3. **Builder** - Placing blocks
4. **Hunter** - Killing mobs
5. **Fisherman** - Catching fish
6. **Woodcutter** - Chopping trees
7. **Explorer** - Discovering new chunks

**Reference:** [blockhaven-planning-doc.md](blockhaven-planning-doc.md#phase-3-jobs-reborn--economy-balancing)

#### 3.2 Set World Multipliers

**File:** `plugins/configs/Jobs/config.yml`

```yaml
world-multipliers:
  survival_easy: 1.0
  survival_hard: 1.5
  resource: 1.0
```

#### 3.3 Configure Economy Settings

**File:** `plugins/configs/EssentialsX/config.yml`

```yaml
economy:
  starting-balance: 500
  max-money: 10000000
  currency-symbol: ''
  currency-name-singular: coin
  currency-name-plural: coins
```

#### 3.4 Test Economy

```bash
# Give yourself test money
/eco give <player> 1000

# Check balance
/balance

# Join a job
/jobs join miner

# Test earning (mine blocks, verify payment)
```

**Deliverables:**
- [ ] All 7 jobs configured with appropriate payouts
- [ ] World multipliers set (survival_hard = 1.5x)
- [ ] Economy settings configured
- [ ] Tested job earnings in each world
- [ ] Documentation: `docs/ECONOMY.md` (optional)

---

## Phase 4: World Generation & PlotSquared Setup

**Estimated Time:** 3-4 hours (includes world generation time)

**Goal:** Create all 6 main worlds with proper settings and configure PlotSquared for creative plots.

### Tasks

#### 4.1 Create All Worlds

**Run in-game or via RCON** - See [mc-server/docs/WORLDS.md](mc-server/docs/WORLDS.md)

```bash
# Access RCON
docker exec -it blockhaven-mc rcon-cli

# Run world creation commands from WORLDS.md
/mv create survival_easy normal -t FLAT
/mv create survival_hard normal -t AMPLIFIED
/mv create creative_flat normal -t FLAT
/mv create creative_terrain normal
/mv create resource normal
/mv create spawn normal -g VoidGen

# Configure each world (difficulty, gamemode, etc.)
# See WORLDS.md for complete command sequence
```

**Expected generation time:**
- Flat worlds: 1-2 minutes each
- Amplified world (survival_hard): 10-15 minutes
- Normal worlds: 5 minutes each
- Void world (spawn): Instant

#### 4.2 Configure Multiverse-Inventories

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

Apply configuration:
```bash
/mvinv reload
```

#### 4.3 Set Up PlotSquared

**Create plot areas:**

```bash
# Creative Flat - 64x64 plots
/plot area create creative_flat
# Follow prompts: size 64, path width 7, ground height 64

# Creative Terrain - 128x128 plots
/plot area create creative_terrain
# Follow prompts: size 128, path width 10
```

**Configure plot limits** (via LuckPerms or PlotSquared config):
- Default: 3 plots
- Friend: 5 plots
- Family: 10 plots
- VIP: 20 plots
- Lifetime VIP: Unlimited

#### 4.4 Set World Borders

```bash
/mv modify set worldborder 10000 survival_easy
/mv modify set worldborder 10000 survival_hard
/mv modify set worldborder 5000 resource
/mv modify set worldborder 5000 creative_flat
/mv modify set worldborder 10000 creative_terrain
/mv modify set worldborder 500 spawn
```

**Deliverables:**
- [ ] All 6 worlds created and verified
- [ ] Multiverse-Inventories groups configured
- [ ] PlotSquared areas created for both creative worlds
- [ ] World borders set
- [ ] Test inventory sharing (items persist between survival worlds)
- [ ] Test inventory isolation (creative items don't transfer to survival)

---

## Phase 5: GriefPrevention Multi-World Config

**Estimated Time:** 1 hour

**Goal:** Configure different claim rates for each survival world.

### Tasks

#### 5.1 Configure Per-World Claim Rates

**File:** `plugins/configs/GriefPrevention/worlds.yml`

```yaml
worlds:
  survival_easy:
    claims:
      enabled: true
      blocks_per_hour: 200    # 2x multiplier
      initial_blocks: 100
      max_accrued: 50000

  survival_hard:
    claims:
      enabled: true
      blocks_per_hour: 50     # 0.5x multiplier
      initial_blocks: 100
      max_accrued: 50000

  resource:
    claims:
      enabled: false

  creative_flat:
    claims:
      enabled: false

  creative_terrain:
    claims:
      enabled: false

  spawn:
    claims:
      enabled: false
```

#### 5.2 Test Claims

```bash
# Give yourself a golden shovel
/giveme golden_shovel

# Test claiming in survival_easy
/tp survival_easy
# Use golden shovel to create claim, wait 1 hour, verify 200 blocks earned

# Test claiming in survival_hard
/tp survival_hard
# Verify 50 blocks/hour earn rate
```

**Deliverables:**
- [ ] GriefPrevention configured for all worlds
- [ ] Claim rates verified (200/hr easy, 50/hr hard)
- [ ] Claims disabled in non-survival worlds
- [ ] Documentation updated if needed

---

## Phase 6: Private Worlds System (Custom Skript)

**Estimated Time:** 4-6 hours (custom development)

**Goal:** Implement player-owned invite-only worlds using Multiverse + Skript.

### Tasks

#### 6.1 Design Skript Logic

**File:** `plugins/configs/Skript/scripts/privateworlds.sk`

**Required functionality:**
- Check player rank permission (`privateworld.create.1` or `privateworld.create.3`)
- Create world with Multiverse-Core API
- Store world ownership in YAML config
- Manage invite list (add/remove players)
- Teleport to private world
- Delete world (with confirmation)
- Auto-unload empty worlds after 30 minutes

#### 6.2 Implement Commands

```
/pworld create <name>       # Create private world
/pworld invite <player>     # Invite player
/pworld kick <player>       # Remove access
/pworld list                # List your worlds
/pworld tp <worldname>      # Teleport
/pworld delete <name>       # Delete (confirmation)
```

#### 6.3 World Storage Format

**File:** `plugins/Skript/data/privateworlds.yml`

```yaml
worlds:
  pw_a1b2c3d4_MyIsland:
    owner: PlayerUUID
    owner_name: PRLLAGER207
    created: 2026-01-10T15:30:00Z
    invited_players:
      - PlayerUUID2
      - PlayerUUID3
    last_activity: 2026-01-10T16:45:00Z
```

#### 6.4 Test Private Worlds

- [ ] Create private world as Family rank
- [ ] Invite another player
- [ ] Verify invited player can join
- [ ] Verify non-invited player cannot join
- [ ] Test world limits (1 for Family, 3 for VIP)
- [ ] Test world deletion
- [ ] Test auto-unload after inactivity

**Deliverables:**
- [ ] Complete `privateworlds.sk` script
- [ ] All commands functional
- [ ] World limits enforced by rank
- [ ] Documentation: `docs/PRIVATE-WORLDS.md`

---

## Phase 7: Monetization Setup (Tebex)

**Estimated Time:** 2-3 hours

**Goal:** Configure Tebex store with all donation packages.

### Tasks

#### 7.1 Create Tebex Account

1. Go to https://www.tebex.io/
2. Create account
3. Set up store: "BlockHaven Store"
4. Connect payment gateway (Stripe or PayPal)

#### 7.2 Install Tebex Plugin

Already included in SPIGET_RESOURCES, but verify:

```bash
/tebex secret <your-secret-key>
```

#### 7.3 Create Packages

**Use configurations from:** [mc-server/docs/MONETIZATION.md](mc-server/docs/MONETIZATION.md)

Create 4 packages:
1. **Friend Rank** - $4.99/month
2. **Family Rank** - $9.99/month
3. **VIP Rank** - $19.99/month
4. **Lifetime VIP** - $99.99 one-time

For each package, configure:
- Commands to execute on purchase
- Commands to execute on expiry
- Package description
- Category: Ranks
- Limit: 1 per player

#### 7.4 Test Purchases

1. Create test package ($0.01)
2. Purchase with test credit card
3. Verify LuckPerms rank updated
4. Verify permissions granted
5. Test expiry (remove rank)

**Deliverables:**
- [ ] Tebex account created
- [ ] Payment gateway connected
- [ ] All 4 packages created
- [ ] Test purchases verified
- [ ] Store embedded on blockhaven.gg (future)

---

## Phase 8: Safety & Moderation

**Estimated Time:** 2 hours

**Goal:** Configure ChatSentry for family-friendly chat and set up moderation tools.

### Tasks

#### 8.1 Configure ChatSentry

**File:** `plugins/configs/ChatSentry/config.yml`

```yaml
filters:
  profanity:
    enabled: true
    severity: high
    action: block

  urls:
    enabled: true
    whitelist:
      - youtube.com
      - youtu.be
      - imgur.com
      - discord.gg/blockhaven

  spam:
    enabled: true
    max_messages: 3
    time_window: 5s

  caps:
    enabled: true
    max_percentage: 50
```

**File:** `plugins/configs/ChatSentry/blacklist.txt`
- Add profanity wordlist
- Add server advertising patterns

#### 8.2 Configure Staff Permissions

Via LuckPerms:

**Helper:**
- `essentials.warn`
- `essentials.mute`
- `essentials.kick`

**Moderator:**
- Inherits Helper
- `essentials.ban`
- `essentials.unban`
- `essentials.vanish`
- `coreprotect.inspect`
- `coreprotect.lookup`

**Admin:**
- All permissions (`*` or specific nodes)

#### 8.3 Test Moderation

- [ ] Test profanity filter
- [ ] Test spam filter
- [ ] Test caps filter
- [ ] Test URL blocking (allow whitelisted URLs)
- [ ] Test staff commands (/warn, /mute, /ban)
- [ ] Test CoreProtect rollback

**Deliverables:**
- [ ] ChatSentry configured
- [ ] Moderation permissions set
- [ ] Documentation: `docs/MODERATION.md`

---

## Phase 9: Polish & Launch

**Estimated Time:** 1-2 weeks (including testing)

**Goal:** Final testing, documentation, and public launch.

### Tasks

#### 9.1 Build Spawn Hub

- [ ] Design spawn hub layout (WorldEdit recommended)
- [ ] Build central hub area
- [ ] Create portals to all 6 worlds (Multiverse-Portals)
- [ ] Add tutorial NPCs (ZNPCs)
- [ ] Protect spawn with WorldGuard

#### 9.2 Configure BlueMap

**File:** `plugins/configs/BlueMap/core.conf`

- [ ] Enable all 6 worlds on map
- [ ] Configure staff-only access (nginx reverse proxy)
- [ ] Set render distance and update frequency
- [ ] Test map access at http://localhost:8100

#### 9.3 Set Up Discord Integration

**DiscordSRV Configuration:**

1. Create Discord bot at https://discord.com/developers/applications
2. Get bot token and channel IDs
3. Configure in `.env`:
   ```bash
   DISCORD_BOT_TOKEN=your_token
   DISCORD_CHANNEL_ID=your_channel_id
   ```
4. Set up channels:
   - `#minecraft-chat` - Bidirectional chat bridge
   - `#join-leave` - Player join/leave announcements
   - `#staff-console` - Read-only console (staff only)

**Test Discord features:**
- [ ] Chat messages bridge both ways
- [ ] Join/leave announcements work
- [ ] Achievement broadcasts work
- [ ] Staff console shows server output

#### 9.4 Write Policies

**Required documents:**
- [ ] Terms of Service
- [ ] Privacy Policy (GDPR/CCPA compliant)
- [ ] Server Rules
- [ ] Ban Appeal Process

#### 9.5 Beta Testing

**Duration:** 1-2 weeks

- [ ] Invite 10-20 friends/family
- [ ] Test all systems under load
- [ ] Collect feedback
- [ ] Fix bugs and issues
- [ ] Balance economy and jobs
- [ ] Test private worlds
- [ ] Test donation packages

#### 9.6 Create Server Listings

**Platforms:**
- [ ] Planet Minecraft: https://www.planetminecraft.com/
- [ ] Minecraft-Server-List: https://minecraft-server-list.com/
- [ ] TopG: https://topg.org/
- [ ] MC-Server-List: https://mc-server-list.com/

**Listing content:**
- Server description (use from README.md)
- Screenshots of spawn hub, worlds
- Banner image (1920x400px recommended)
- Server IP: `play.blockhaven.gg`
- Features list
- Voting rewards (optional)

#### 9.7 Soft Launch

- [ ] Remove whitelist
- [ ] Set max players to 50 (half of target 100)
- [ ] Monitor performance
- [ ] Respond to issues quickly
- [ ] Gather player feedback

#### 9.8 Marketing Push

**Channels:**
- [ ] Social media (Twitter, Reddit r/mcservers)
- [ ] YouTube (server trailer)
- [ ] Discord partnerships
- [ ] Friends & family referrals

**Deliverables:**
- [ ] Spawn hub complete
- [ ] Discord server active
- [ ] BlueMap accessible
- [ ] All policies written
- [ ] Beta testing complete
- [ ] Server listings published
- [ ] Soft launch successful
- [ ] Marketing campaign active

---

## Production Deployment (When Ready)

### Deploy to Hetzner VPS

**Option A: DokPloy (Recommended)**

1. Set up DokPloy on Hetzner VPS
2. Connect to GitHub repository
3. Configure environment variables in DokPloy
4. Deploy automatically on push

**Option B: Manual Deployment**

See [mc-server/docs/SETUP.md](mc-server/docs/SETUP.md) - "Manual Docker Compose Deployment"

### Post-Deployment Checklist

- [ ] Firewall configured (UFW)
- [ ] Fail2ban installed
- [ ] UptimeRobot monitoring set up
- [ ] S3 backups configured
- [ ] DNS configured: play.blockhaven.gg → VPS IP
- [ ] SSL/TLS for BlueMap (nginx reverse proxy)
- [ ] Resource world reset cron job set up

---

## Long-Term Roadmap

### Month 1-2: Growth & Optimization
- Monitor server performance
- Upgrade to CPX41 (16GB RAM) if needed
- Recruit staff team (Helpers, Moderators)
- Run building competitions
- Optimize economy based on player behavior

### Month 3-6: Feature Expansion
- Develop marketing website (React/Vue)
- Add seasonal events (Halloween, Christmas)
- Expand private worlds features
- Add custom plugins or features
- Implement voting rewards

### Month 6+: Community Building
- Expand staff team
- Create content creator program
- Partner with other servers
- Consider additional game modes
- Build hall of fame for Lifetime VIPs

---

## Quick Reference

### Key Documentation Files

| File | Purpose |
|------|---------|
| [SETUP.md](mc-server/docs/SETUP.md) | Deployment and troubleshooting |
| [PLUGINS.md](mc-server/docs/PLUGINS.md) | Complete plugin reference |
| [WORLDS.md](mc-server/docs/WORLDS.md) | World setup and configuration |
| [MONETIZATION.md](mc-server/docs/MONETIZATION.md) | Tebex packages and pricing |
| [blockhaven-planning-doc.md](blockhaven-planning-doc.md) | Complete project planning |

### Useful Commands

```bash
# Server management
docker-compose up -d              # Start server
docker-compose logs -f minecraft  # View logs
docker exec -it blockhaven-mc rcon-cli  # RCON access

# Backups
./scripts/backup.sh               # Manual backup
./scripts/restore.sh <file>       # Restore backup

# Plugin management
/plugins                          # List plugins
/reload                           # Reload config (use sparingly)
```

---

## Support & Resources

- **Planning Document:** [blockhaven-planning-doc.md](blockhaven-planning-doc.md)
- **Discord:** [Coming soon]
- **Email:** support@blockhaven.gg
- **Issues:** GitHub Issues (private repository)

---

**Good luck with BlockHaven! 🚀**

*Remember: Build incrementally, test thoroughly, and have fun!*
