# BlockHaven SMP - Minecraft Server Project

<p align="center">
  <strong>Family-Friendly Anti-Griefer Survival & Creative!</strong>
</p>

<p align="center">
  <a href="https://bhsmp.com">🌐 Website</a> •
  <a href="mc-server/docs/SETUP.md">📖 Setup Guide</a> •
  <a href="mc-server/docs/PLUGINS.md">🔌 Plugins</a> •
  <a href="mc-server/docs/WORLDS.md">🌍 Worlds</a>
</p>

---

## Overview

BlockHaven is a cross-platform Minecraft server supporting both **Java Edition** and **Bedrock Edition** players through Geyser/Floodgate integration.

### Features

✅ **12 Worlds:** 3 Survival worlds (Easy/Normal/Hard) with Nether & End, 2 Creative worlds, Spawn Hub
✅ **Cross-Platform:** Java + Bedrock Edition support
✅ **Grief-Free:** Advanced land claims with UltimateLandClaim
✅ **Economy System:** Jobs, player shops, balanced payouts
✅ **Private Worlds:** Premium players can create invite-only worlds
✅ **Plot System:** Creative building plots (64x64 and 128x128)
✅ **Family-Friendly:** Chat filtering, moderation tools
✅ **Live Map:** BlueMap 3D web visualization
✅ **Discord Integration:** Chat bridge, notifications, analytics

### Technical Stack

- **Platform:** Paper 1.21.11 (Minecraft Java Edition)
- **Deployment:** Docker + Docker Compose
- **Hosting:** Hetzner VPS (8GB RAM → 16GB)
- **Plugins:** 25+ (LuckPerms, Multiverse, GriefPrevention, PlotSquared, Geyser, BlueMap, etc.)
- **CI/CD:** DokPloy automation

---

## Quick Start

### Prerequisites

- Docker & Docker Compose installed
- 8GB+ RAM available
- Ports: 25565 (Java), 19132 (Bedrock), 8100 (BlueMap), 8804 (Plan)

### Local Development

```bash
# Clone repository
git clone <repo-url>
cd blockhaven/mc-server

# Configure environment
cp .env.example .env
nano .env  # Set RCON_PASSWORD and SERVER_OPS

# Start server
docker-compose up -d

# View logs
docker-compose logs -f minecraft

# Connect
# Java Edition: localhost:25565
# Bedrock Edition: localhost:19132
```

**Full setup guide:** [mc-server/docs/SETUP.md](mc-server/docs/SETUP.md)

---

## Project Structure

```
blockhaven/
├── mc-server/                  # Minecraft server (Docker-based)
│   ├── docker-compose.yml      # Main Docker configuration
│   ├── .env.example            # Environment variables template
│   ├── scripts/                # Backup, restore, utility scripts
│   ├── extras/                 # Plugin downloads list
│   ├── plugins/configs/        # Plugin configuration templates
│   ├── data/                   # Server data (worlds, plugins) - gitignored
│   ├── backups/                # Automated backups - gitignored
│   └── docs/                   # Documentation
│       ├── SETUP.md            # Setup & deployment guide
│       ├── PLUGINS.md          # Plugin reference
│       ├── WORLDS.md           # World configuration
│       └── MONETIZATION.md     # Tebex/donation setup
├── web/                        # Marketing website (future)
│   └── .gitkeep
├── blockhaven-planning-doc.md  # Complete planning document
└── README.md                   # This file
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [SETUP.md](mc-server/docs/SETUP.md) | Installation, deployment, troubleshooting |
| [PLUGINS.md](mc-server/docs/PLUGINS.md) | Complete plugin reference & configuration |
| [WORLDS.md](mc-server/docs/WORLDS.md) | World setup, inventory groups, portals |
| [MONETIZATION.md](mc-server/docs/MONETIZATION.md) | Tebex packages, pricing, revenue model |
| [blockhaven-planning-doc.md](blockhaven-planning-doc.md) | Full project planning document |

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

## Donation Ranks

| Rank | Price | Benefits |
|------|-------|----------|
| **Friend** | $4.99/mo | Chat colors, 5 plots, 3 homes, particle effects |
| **Family** | $9.99/mo | 1 private world, 10 plots, 5 homes, custom nickname |
| **VIP** | $19.99/mo | 3 private worlds, 20 plots, 10 homes, fly in spawn |
| **Lifetime VIP** | $99.99 | All VIP perks forever, unlimited plots |

**Fair Play:** NO pay-to-win! Only cosmetics and convenience features.

---

## Development Status

**Current Phase:** Phase 1 Complete ✅ | Ready for local testing

- [x] **Phase 1:** Docker foundation, plugin stack validation
- [ ] **Phase 2:** LuckPerms configuration (ranks, permissions)
- [ ] **Phase 3:** Jobs & economy balancing
- [ ] **Phase 4:** World generation & PlotSquared setup
- [ ] **Phase 5:** GriefPrevention multi-world config
- [ ] **Phase 6:** Private worlds system (custom Skript)
- [ ] **Phase 7:** Monetization (Tebex integration)
- [ ] **Phase 8:** Safety & moderation (ChatSentry)
- [ ] **Phase 9:** Polish & launch

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
