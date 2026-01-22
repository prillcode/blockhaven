# BlockHaven - Final World Configuration

> **Document Created:** January 21, 2026
> **Status:** Active configuration on local development server

This document reflects the actual world setup on BlockHaven, which differs from the original plan in [CREATE-WORLDS-GUIDE.md](CREATE-WORLDS-GUIDE.md).

---

## World Overview

| World | Alias | Environment | Gamemode | Difficulty | Nether/End |
|-------|-------|-------------|----------|------------|------------|
| **spawn** | Spawn_Hub | normal | adventure | peaceful | No |
| **survival_easy** | SMP_Plains | normal | survival | easy | Yes |
| **survival_normal** | SMP_Ravine | normal | survival | normal | Yes |
| **survival_hard** | SMP_Cliffs | normal | survival | hard | Yes |
| **creative_flat** | Creative_Plots | normal | creative | peaceful | No |
| **creative_terrain** | Creative_Hills | normal | creative | peaceful | No |

### Nether/End World Pairs

| Parent World | Nether World | End World |
|--------------|--------------|-----------|
| survival_easy | survival_easy_nether | survival_easy_the_end |
| survival_normal | survival_normal_nether | survival_normal_the_end |
| survival_hard | survival_hard_nether | survival_hard_the_end |

**Note:** `spawn_nether` and `spawn_the_end` were deleted as they are not needed for the spawn hub.

---

## How Nether/End Linking Works

Multiverse-NetherPortals uses a **naming convention** to auto-link worlds:

```yaml
# From plugins/Multiverse-NetherPortals/config.yml
portal-auto-link-when:
  nether:
    prefix: ''
    suffix: _nether
  end:
    prefix: ''
    suffix: _the_end
```

This means:
- A nether portal in `survival_easy` automatically links to `survival_easy_nether`
- An end portal in `survival_easy` automatically links to `survival_easy_the_end`
- No manual configuration required if naming convention is followed

---

## RCON Commands Used

### Creating Nether/End Worlds

```bash
# Survival Easy
mv create survival_easy_nether NETHER
mv create survival_easy_the_end THE_END
mv modify survival_easy_nether set difficulty easy
mv modify survival_easy_the_end set difficulty easy

# Survival Normal
mv create survival_normal_nether NETHER
mv create survival_normal_the_end THE_END
mv modify survival_normal_nether set difficulty normal
mv modify survival_normal_the_end set difficulty normal

# Survival Hard
mv create survival_hard_nether NETHER
mv create survival_hard_the_end THE_END
mv modify survival_hard_nether set difficulty hard
mv modify survival_hard_the_end set difficulty hard
```

### Useful Multiverse Commands

```bash
# List all worlds
mv list

# Teleport to a world
mv tp <worldname>

# Get world info
mv info <worldname>

# Modify world properties
mv modify <worldname> set <property> <value>

# Examples:
mv modify survival_easy set difficulty normal
mv modify creative_flat set gamemode creative
mv modify spawn set pvp false
```

---

## Directory Structure

```
/data/
├── spawn/                      # Main hub world (adventure mode)
├── survival_easy/              # Easy survival (SMP_Plains)
├── survival_easy_nether/       # Nether for easy survival
├── survival_easy_the_end/      # End for easy survival
├── survival_normal/            # Normal survival (SMP_Ravine)
├── survival_normal_nether/     # Nether for normal survival
├── survival_normal_the_end/    # End for normal survival
├── survival_hard/              # Hard survival (SMP_Cliffs)
├── survival_hard_nether/       # Nether for hard survival
├── survival_hard_the_end/      # End for hard survival
├── creative_flat/              # Flat creative (Creative_Plots)
├── creative_terrain/           # Terrain creative (Creative_Hills)
└── plugins/
    ├── Multiverse-Core/
    │   └── worlds.yml          # World definitions
    ├── Multiverse-NetherPortals/
    │   └── config.yml          # Portal linking config
    └── Multiverse-Portals/
        └── config.yml          # Custom portals
```

---

## Differences from Original Plan

| Aspect | Original Plan | Actual Implementation |
|--------|---------------|----------------------|
| Resource world | Planned | Not created |
| Spawn nether/end | Planned as needed | Deleted (not needed) |
| World count | ~6-7 worlds | 12 worlds total |

---

## Backup Location

Pre-change backup created on January 21, 2026:
```
/home/prill/projects/blockhaven/backups/20260121_214330/
├── spawn/
├── spawn_nether/
├── spawn_the_end/
├── survival_easy/
├── survival_normal/
├── survival_hard/
├── creative_flat/
├── creative_terrain/
└── plugins/
    ├── Multiverse-Core/
    ├── Multiverse-NetherPortals/
    └── Multiverse-Portals/
```

---

## Testing Portal Links

To verify portals work correctly:

1. Join each survival world
2. Build a nether portal and light it
3. Enter the portal - should arrive in the matching `_nether` world
4. Return through the portal - should return to the correct overworld
5. Repeat for end portals (requires stronghold or creative mode)

---

## Troubleshooting

### Portal goes to wrong world
Check the naming convention matches exactly:
- `worldname_nether` (not `worldname_the_nether`)
- `worldname_the_end` (not `worldname_end`)

### World not loading
```bash
mv load <worldname>
```

### Check world exists
```bash
mv list --raw
```

### View world properties
```bash
mv info <worldname>
```
