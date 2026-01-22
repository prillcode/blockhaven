# BlockHaven SMP - Minecraft Server Project

<p align="center">
  <strong>Family-Friendly Anti-Griefer Survival & Creative!</strong>
</p>

<p align="center">
  <a href="https://bhsmp.com">🌐 Website</a> •
  <a href="mc-server/docs/PLUGINS.md">🔌 Plugins</a> •
  <a href="mc-server/docs/CREATED-WORLDS-FINAL.md">🌍 Worlds</a>
</p>

---

## Overview

BlockHaven is a cross-platform Minecraft server supporting both **Java Edition** and **Bedrock Edition** players through Geyser/Floodgate integration.

### Features

✅ **12 Worlds:** 3 Survival worlds (Easy/Normal/Hard) with Nether & End, 2 Creative worlds, Spawn Hub
✅ **Cross-Platform:** Java + Bedrock Edition support
✅ **Grief-Free:** Advanced land claims with UltimateLandClaim
✅ **Economy System:** Jobs, player shops, balanced payouts
✅ **Family-Friendly:** Chat filtering, moderation tools
✅ **Live Map:** BlueMap 3D web visualization
✅ **Discord Integration:** Chat bridge, notifications, analytics

### Technical Stack

- **Platform:** Paper 1.21.11 (Minecraft Java Edition)
- **Deployment:** Docker + Docker Compose
- **Hosting:** Local (Docker) / VPS-ready
- **Plugins:** 16 active (LuckPerms, Multiverse, EssentialsX, Geyser, etc.)
- **CI/CD:** DokPloy automation

---

## Quick Start

### Prerequisites

- Docker & Docker Compose installed
- 8GB+ RAM available
- Ports: 25565 (Java), 19132 (Bedrock)

### Local Development

```bash
# Clone repository
git clone <repo-url>
cd blockhaven/mc-server

# Start local server
docker compose -f docker-compose.local.yml up -d

# View logs
docker logs -f blockhaven-local

# Connect
# Java Edition: localhost:25565
# Bedrock Edition: localhost:19132
```

### Remote/VPS Deployment

```bash
# Configure environment
cp .env.example .env
nano .env  # Set RCON_PASSWORD and SERVER_OPS

# Start server
docker compose up -d

# Restore from S3 backup (to sync with local)
./scripts/s3-restore.sh
```

**AWS deployment:** [mc-server/aws/README.md](mc-server/aws/README.md)

---

## Project Structure

```
blockhaven/
├── mc-server/                  # Minecraft server (Docker-based)
│   ├── docker-compose.yml      # Remote/VPS configuration
│   ├── docker-compose.local.yml # Local development
│   ├── .env.example            # Environment variables template
│   ├── scripts/                # Backup, restore, utility scripts
│   ├── aws/                    # AWS EC2 deployment (CloudFormation)
│   ├── extras/                 # Server icon, resources
│   ├── plugins/                # Plugin JARs and configs
│   └── docs/                   # Documentation
│       ├── PLUGINS.md          # Plugin reference
│       ├── PLUGINS-QUICK-REF.md # Quick command reference
│       └── CREATED-WORLDS-FINAL.md # World configuration
├── web/                        # Marketing website (future)
│   └── .gitkeep
└── README.md                   # This file
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [PLUGINS.md](mc-server/docs/PLUGINS.md) | Complete plugin reference & configuration |
| [PLUGINS-QUICK-REF.md](mc-server/docs/PLUGINS-QUICK-REF.md) | Quick command reference |
| [CREATED-WORLDS-FINAL.md](mc-server/docs/CREATED-WORLDS-FINAL.md) | World setup, Nether/End linking, portals |
| [AWS README](mc-server/aws/README.md) | EC2 deployment, costs, helper scripts |

---

## Backup & Restore

BlockHaven uses S3 for backup storage. Scripts are located in `mc-server/scripts/`.

### Backup to S3

```bash
cd mc-server/scripts

# Full backup (stops server for consistency)
./s3-backup.sh

# Quick backup (uses RCON save-all, server stays online)
./s3-backup.sh --no-stop

# Preview what would happen
./s3-backup.sh --dry-run
```

**Options:**
| Flag | Description |
|------|-------------|
| `--no-stop` | Don't stop container (uses RCON save-all instead) |
| `--keep-local` | Keep local tarball after S3 upload |
| `--dry-run` | Preview without executing |

### Restore from S3

```bash
cd mc-server/scripts

# Interactive mode - lists backups and prompts for selection
./s3-restore.sh

# List available backups without restoring
./s3-restore.sh --list

# Restore specific backup (1 = most recent)
./s3-restore.sh --backup 1

# Preview restore
./s3-restore.sh --backup 1 --dry-run
```

**Options:**
| Flag | Description |
|------|-------------|
| `--list` | List available backups and exit |
| `--backup NUM` | Restore backup #NUM (1 = most recent) |
| `--dry-run` | Preview without executing |

### Configuration

Environment variables (defaults shown):
```bash
MC_CONTAINER_NAME=blockhaven-local  # Container to backup/restore
AWS_PROFILE=bgrweb                   # AWS CLI profile
S3_BUCKET=blockhaven-mc-backups      # S3 bucket name
```

---

## Server Details

### Worlds

| World | Alias | Type | Difficulty | Nether/End |
|-------|-------|------|------------|------------|
| **spawn** | Spawn_Hub | Adventure | Peaceful | No |
| **survival_easy** | SMP_Plains | Survival | Easy | Yes |
| **survival_normal** | SMP_Ravine | Survival | Normal | Yes |
| **survival_hard** | SMP_Cliffs | Survival | Hard | Yes |
| **creative_flat** | Creative_Plots | Creative | Peaceful | No |
| **creative_terrain** | Creative_Hills | Creative | Peaceful | No |

Each survival world has its own linked nether and end dimensions (e.g., `survival_easy_nether`, `survival_easy_the_end`).

### Inventory Groups

Configured via Multiverse-Inventories - each group shares all inventory/stats:
- **survival_easy_group:** `survival_easy` + its nether/end
- **survival_normal_group:** `survival_normal` + its nether/end
- **survival_hard_group:** `survival_hard` + its nether/end
- **default:** `spawn` (isolated, adventure mode)
- **Creative Worlds:** Fully isolated (no creative items in survival)

---

## Development Status

**Current Phase:** Local development complete ✅ | AWS deployment ready

- [x] **Phase 1:** Docker foundation, plugin stack validation
- [x] **Phase 2:** World configuration (12 worlds with Nether/End linking)
- [x] **Phase 3:** S3 backup/restore system
- [x] **Phase 4:** AWS EC2 deployment infrastructure
- [ ] **Phase 5:** LuckPerms configuration (ranks, permissions)
- [ ] **Phase 6:** Jobs & economy balancing
- [ ] **Phase 7:** Safety & moderation (ChatSentry)
- [ ] **Phase 8:** Polish & launch

---

## Support

- **Discord:** [Coming soon]
- **Email:** support@bhsmp.com
- **Issues:** GitHub Issues (private repository)

---

## License

Proprietary - All rights reserved.

This project is not open source. Code is shared with authorized contributors only.

---

## Credits

**Owner/Developer:** PRLLAGER207
**Base Repository:** [minecraft-crossplatform-docker](https://github.com/prillcode/minecraft-crossplatform-docker)
**Special Thanks:** itzg (Docker image), Geyser team, Paper team, plugin developers

---

<p align="center">
  <strong>Built with ❤️ for the BlockHaven community</strong>
</p>
