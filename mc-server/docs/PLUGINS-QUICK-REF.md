# BlockHaven Plugins Quick Reference

A quick command reference for the main plugins on BlockHaven Home server.

---

## Land Claims (UltimateLandClaim)

Protect your builds from griefing by claiming land. The plugin supports two modes:
- **CHUNK mode** - Claim entire 16x16 chunks at a time
- **FREE mode** - Use a golden shovel to select custom areas

### Basic Commands

| Command | Description |
|---------|-------------|
| `/claim` | Show claiming instructions |
| `/claim auto` | Toggle auto-claim while walking (CHUNK mode only) |
| `/claim delete` | Delete your current claim |
| `/claim info` | Show details about the claim you're standing in |
| `/claim list` | Display your claim blocks (total, used, available) |
| `/unstuck` | Teleport out if you're stuck in someone's claim |

### Trust System

Grant other players access to your claims with different permission levels:

| Command | Description |
|---------|-------------|
| `/claim trust <player> ACCESS` | Allow entering and using buttons/doors |
| `/claim trust <player> CONTAINER` | ACCESS + open chests and containers |
| `/claim trust <player> BUILD` | CONTAINER + place and break blocks |
| `/claim trust <player> MANAGER` | BUILD + can trust/untrust other players |
| `/claim untrust <player>` | Remove a player's trust |

**Note:** Trust is per-claim and doesn't carry between claims. Only MANAGER level can trust/untrust others.

### Aliases
- `/claim` = `/claims` = `/c`
- `/unstuck` = `/escape` = `/claimstuck`

---

## Jobs Reborn (with Vault Economy)

Get paid for doing activities! Join jobs to earn money as you play. Money earned also gives you experience to level up and earn more.

### Available Jobs

Hunter, Farmer, Enchanter, Explorer, Woodcutter, Miner, Builder, Digger, Crafter, Fisherman, Weaponsmith, Brewer

### Basic Commands

| Command | Description |
|---------|-------------|
| `/jobs browse` | Open the jobs GUI to see all available jobs |
| `/jobs join <job>` | Join a job (e.g., `/jobs join Miner`) |
| `/jobs leave <job>` | Leave a job |
| `/jobs leaveall` | Leave all your jobs |
| `/jobs info <job>` | See details about a specific job |
| `/jobs stats` | View your personal job statistics |

### Progress & Rankings

| Command | Description |
|---------|-------------|
| `/jobs top` | View the global job leaderboard |
| `/jobs gtop` | Same as `/jobs top` |
| `/jobs points` | Check your accumulated points |
| `/jobs quests` | View available quests for extra rewards |
| `/jobs log` | View your recent job activity |

### Utility Commands

| Command | Description |
|---------|-------------|
| `/jobs toggle actionbar` | Toggle the action bar display on/off |
| `/jobs toggle bossbar` | Toggle the boss bar display on/off |
| `/jobs itembonus` | See bonus multipliers for items you're holding |
| `/jobs blockinfo` | Get info about a block's job value |

### How It Works

1. Browse available jobs with `/jobs browse`
2. Join up to 3 jobs (default limit)
3. Do activities related to your job (mining, farming, etc.)
4. Earn money and experience automatically
5. Level up to earn more per action!

---

## EssentialsX

The core utility plugin providing teleportation, homes, economy, and more.

### Teleportation

| Command | Description |
|---------|-------------|
| `/tpa <player>` | Request to teleport to another player |
| `/tpahere <player>` | Request another player to teleport to you |
| `/tpaccept` or `/tpyes` | Accept a teleport request |
| `/tpdeny` or `/tpno` | Deny a teleport request |
| `/back` | Return to your last location (after teleport or death) |
| `/spawn` | Teleport to the world spawn |

### Homes

| Command | Description |
|---------|-------------|
| `/sethome` | Set your default home |
| `/sethome <name>` | Set a named home (e.g., `/sethome base`) |
| `/home` | Teleport to your default home |
| `/home <name>` | Teleport to a named home |
| `/delhome <name>` | Delete a home |
| `/homes` | List all your homes |

### Warps (Server Locations)

| Command | Description |
|---------|-------------|
| `/warp <name>` | Teleport to a server warp |
| `/warps` | List available warps |
| `/setwarp <name>` | Create a warp (admin) |
| `/delwarp <name>` | Delete a warp (admin) |

### Economy

| Command | Description |
|---------|-------------|
| `/balance` or `/bal` | Check your money |
| `/balance <player>` | Check another player's balance |
| `/pay <player> <amount>` | Send money to another player |
| `/baltop` | See the richest players |
| `/worth` | Check the value of the item in your hand |

### Kits

| Command | Description |
|---------|-------------|
| `/kit` | List available kits |
| `/kit <name>` | Claim a kit |

### Messaging

| Command | Description |
|---------|-------------|
| `/msg <player> <message>` | Send a private message |
| `/r <message>` | Reply to the last message |
| `/mail send <player> <msg>` | Send offline mail |
| `/mail read` | Read your mail |
| `/mail clear` | Clear your mail |

### Player Utilities

| Command | Description |
|---------|-------------|
| `/nick <nickname>` | Set your display name |
| `/realname <nick>` | See a player's real name |
| `/seen <player>` | Check when a player was last online |
| `/afk` | Toggle AFK status |
| `/suicide` | Kill yourself (useful when stuck) |

### Admin/OP Commands

| Command | Description |
|---------|-------------|
| `/heal [player]` | Restore health |
| `/feed [player]` | Restore hunger |
| `/god [player]` | Toggle invincibility |
| `/fly [player]` | Toggle flight mode |
| `/gamemode <mode>` | Change gamemode (survival, creative, etc.) |
| `/vanish` | Hide from other players |
| `/time day` | Set time to day |
| `/time night` | Set time to night |
| `/weather clear` | Clear the weather |
| `/give <player> <item> [amount]` | Give items |
| `/tp <player>` | Teleport to a player instantly (no request) |
| `/tpall` | Teleport everyone to you |
| `/broadcast <message>` | Send a server-wide message |
| `/mute <player>` | Mute a player |
| `/kick <player>` | Kick a player |
| `/ban <player>` | Ban a player |

---

## Quick Tips

### For New Players
1. **Claim your base!** Use `/claim` to protect your builds
2. **Set a home** with `/sethome` so you can always get back
3. **Join a job** with `/jobs browse` to start earning money
4. **Check your balance** with `/bal` to see your earnings

### Useful Combos
- Died and lost your stuff? Use `/back` to return to your death location
- Want to play with a friend? Use `/tpa <friend>` to request teleport
- Need to share your base? Use `/claim trust <friend> BUILD`

---

## Additional Resources

- [UltimateLandClaim on SpigotMC](https://www.spigotmc.org/resources/ultimatelandclaim.131608/)
- [Jobs Reborn Documentation](https://www.zrips.net/jobs/)
- [EssentialsX Commands Reference](https://essinfo.xeya.me/commands.html)
