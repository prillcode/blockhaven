# BlockHaven Plugin Guide

## Plugin Stack Overview

BlockHaven currently runs **16 plugins** for cross-platform support, grief prevention, economy, and multi-world management.

**Loaded Plugins:**
CMILib, Essentials, floodgate, Geyser-Spigot, Jobs, LuckPerms, Multiverse-Core, Multiverse-Inventories, Multiverse-NetherPortals, Multiverse-Portals, UltimateLandClaim, Vault, ViaVersion, VoidGen, WorldEdit, WorldGuard

---

## Core Plugins

### Cross-Platform Support

#### **Geyser-Spigot** + **floodgate**
- **Purpose:** Allow Bedrock Edition players to join Java Edition server
- **Bedrock Port:** 19132 UDP
- **Player Prefix:** `.` (dot before username for Bedrock players)
- **Documentation:** https://geysermc.org/

#### **ViaVersion**
- **Purpose:** Allow players on newer Minecraft versions to connect
- **Note:** Helps with version compatibility during MC updates

---

### Grief Prevention & Land Claims

#### **UltimateLandClaim**
- **Purpose:** Land claims system for survival worlds
- **Modes:**
  - CHUNK mode - Claim entire 16x16 chunks
  - FREE mode - Use golden shovel to select custom areas
- **Commands:**
  - `/claim` - Show claiming instructions
  - `/claim auto` - Toggle auto-claim while walking (CHUNK mode)
  - `/claim delete` - Delete your current claim
  - `/claim info` - Show details about current claim
  - `/claim list` - Display your claim blocks
  - `/claim trust <player> <level>` - Grant access (ACCESS, CONTAINER, BUILD, MANAGER)
  - `/claim untrust <player>` - Remove trust
  - `/unstuck` - Teleport out if stuck in someone's claim

See [PLUGINS-QUICK-REF.md](PLUGINS-QUICK-REF.md) for detailed command reference.

---

### Permissions & Ranks

#### **LuckPerms**
- **Purpose:** Permission management and rank system
- **Storage:** YAML (local files)
- **Web Editor:** https://luckperms.net/editor

**Key Commands:**
```bash
/lp user <player> info                    # View player info
/lp user <player> parent add <rank>       # Add rank
/lp user <player> permission set <perm>   # Set permission
/lp editor                                # Open web editor
```

---

### Economy System

#### **Jobs Reborn** (Jobs)
- **Purpose:** Earn money by performing job tasks
- **Dependency:** CMILib (auto-loaded)

**Available Jobs:**
Hunter, Farmer, Enchanter, Explorer, Woodcutter, Miner, Builder, Digger, Crafter, Fisherman, Weaponsmith, Brewer

**Commands:**
```bash
/jobs browse           # View available jobs (GUI)
/jobs join <job>       # Join a job
/jobs leave <job>      # Leave a job
/jobs stats            # View your earnings
/jobs top              # View leaderboard
```

#### **Vault**
- **Purpose:** Economy API (bridges Essentials economy with other plugins)
- **No configuration needed** - automatically integrates

---

### World Management

#### **Multiverse-Core**
- **Purpose:** Manage multiple worlds
- **Documentation:** https://github.com/Multiverse/Multiverse-Core/wiki

**Key Commands:**
```bash
/mv list                           # List all worlds
/mv tp <world>                     # Teleport to world
/mv create <name> <environment>    # Create world (NORMAL, NETHER, THE_END)
/mv modify <world> set <prop> <val># Modify world properties
/mv info <world>                   # Get world info
/mv delete <world>                 # Delete world (requires confirm)
```

#### **Multiverse-NetherPortals**
- **Purpose:** Link nether/end portals to correct worlds
- **Auto-linking:** Uses naming convention `worldname_nether` and `worldname_the_end`

#### **Multiverse-Portals**
- **Purpose:** Create custom portals between worlds
- **Commands:**
```bash
/mvp create <name> <destination>   # Create portal
/mvp list                          # List portals
/mvp remove <name>                 # Delete portal
```

#### **Multiverse-Inventories**
- **Purpose:** Separate inventories per world/group
- **Current Groups:**
  - `default`: spawn (isolated)
  - `survival_easy_group`: survival_easy + nether + end
  - `survival_normal_group`: survival_normal + nether + end
  - `survival_hard_group`: survival_hard + nether + end
  - Creative worlds: isolated by default

**Commands:**
```bash
/mvinv list                        # List all groups
/mvinv info <group>                # Group details
/mvinv create-group <name>         # Create new group
/mvinv add-worlds <group> <worlds> # Add worlds to group
/mvinv add-shares <group> all      # Share all inventory/stats
```

#### **VoidGen**
- **Purpose:** Generate void worlds (empty worlds for building)
- **Used for:** Spawn hub world

---

### Utilities

#### **Essentials** (EssentialsX)
- **Purpose:** Core server utilities
- **Features:**
  - `/spawn`, `/sethome`, `/home`
  - `/tpa`, `/tpaccept`
  - Economy backend (`/balance`, `/pay`)
  - Kits, warps, and more

**Key Commands:**
```bash
/spawn                 # Teleport to spawn
/sethome [name]        # Set home
/home [name]           # Teleport home
/tpa <player>          # Request teleport
/tpaccept              # Accept TP request
/balance               # Check money
/pay <player> <amt>    # Send money
```

#### **WorldEdit**
- **Purpose:** Building tools (staff only)
- **Commands:**
```bash
//wand                 # Get selection wand
//copy                 # Copy selection
//paste                # Paste clipboard
//set <block>          # Fill selection
//replace <from> <to>  # Replace blocks
```

#### **WorldGuard**
- **Purpose:** Region protection (staff only)
- **Commands:**
```bash
/rg define <name>              # Create protected region
/rg flag <region> <flag> <val> # Set region flag
/rg info <region>              # View region info
/rg list                       # List regions
```

---

## Plugins NOT Currently Installed

The following plugins were in the original plan but are **not currently loaded**:

| Plugin | Purpose | Status |
|--------|---------|--------|
| GriefPrevention | Land claims | Replaced by UltimateLandClaim |
| PlotSquared | Creative plots | Not installed |
| CoreProtect | Block logging/rollback | Not installed |
| Grim Anticheat | Anti-cheat | Not installed |
| ChatSentry | Chat filtering | Not installed |
| Plan | Analytics dashboard | Not installed |
| BlueMap | 3D web map | Not installed |
| DiscordSRV | Discord integration | Not installed |
| QuickShop-Hikari | Player shops | Not installed |
| Harbor | Sleep voting | Not installed |
| PlaceholderAPI | Variable placeholders | Not installed |
| EssentialsXChat | Chat formatting | Not installed |
| EssentialsXSpawn | Spawn management | Not installed |

These can be added as needed for production deployment.

---

## Plugin Update Process

### Via Docker (Recommended)
Plugins are configured in docker-compose.yml via:
- **SPIGET_RESOURCES** (SpigotMC resource IDs)
- **MODRINTH_PROJECTS** (Modrinth project slugs)

### Manual Update
```bash
# 1. Stop server
docker-compose down

# 2. Remove old plugins
rm -rf data/plugins/*.jar

# 3. Restart (will download fresh)
docker-compose up -d
```

---

## Troubleshooting

### Plugin Not Loading
```bash
# Check plugin file exists
docker exec blockhaven-local ls /data/plugins

# View plugin errors
docker logs blockhaven-local | grep -i "error\|exception"

# List loaded plugins via RCON
docker exec blockhaven-local rcon-cli "plugins"
```

### Permissions Not Working
```bash
# Verify LuckPerms loaded
/lp info

# Check user permissions
/lp user <player> permission check <permission>

# Reload permissions
/lp sync
```

### Economy Not Working
```bash
# Verify Vault loaded
/plugins

# Check balance
/balance

# Jobs not paying? Check Jobs config
```

---

## Additional Resources

- [PLUGINS-QUICK-REF.md](PLUGINS-QUICK-REF.md) - Player-facing command reference
- [CREATED-WORLDS-FINAL.md](CREATED-WORLDS-FINAL.md) - Current world configuration
- [Multiverse Wiki](https://github.com/Multiverse/Multiverse-Core/wiki)
- [LuckPerms Wiki](https://luckperms.net/wiki)
- [Jobs Reborn Wiki](https://www.zrips.net/jobs/)
